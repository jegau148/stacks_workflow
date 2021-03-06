#!/bin/bash
# Launch 'process_radtags' on all the lanes

### Global variable
# Length to which the reads are cut after process_radtags
TRIM_LENGTH=$1
# Name of the enzyme (run 'process_radtags', without options, for list)
ENZYME=$2

# Prepare bacode_lengths.txt from barcodes.txt, 
perl -ne 'chomp; print length."\n"' 01-info_files/barcodes.txt |
    sort -un > 01-info_files/barcode_lengths.txt

# Create barcode files, eg: barcodes_4.txt, barcodes_5.txt ...
cat 01-info_files/barcode_lengths.txt |
    while read b
    do
        perl -sane 'chomp; if (length eq $b) {print $_."\n"}'\
            -- -b=$b 01-info_files/barcodes.txt |
        sort -u > 01-info_files/barcodes_$b".txt"
    done

# Comment 
cat 01-info_files/lane_info.txt |
    while read f
    do
        # Get barcodes for that line, put in barcodes_current_lane.txt
        # Prepare barcode_lengths.txt from barcodes_current_lane.txt
        # Create barcode files
        # Use the -D option to filter only on discarted reads
        cat 01-info_files/barcode_lengths.txt |
        while read b
        do
            mkdir 03-samples/$f
            process_radtags -i gzfastq -f 02-raw/$f".fastq.gz" -o \
                03-samples/$f -b 01-info_files/barcodes_"$b".txt \
                -c -q -r -t $TRIM_LENGTH --barcode_dist\
                --filter_illumina 3 -E phred33 -e $ENZYME
        done
    done

