#!/bin/bash -ue
blastn -num_threads 2 -db DB/blastDB -query input.2.fasta -outfmt '6' -evalue 1e-3 -out input.blastout
