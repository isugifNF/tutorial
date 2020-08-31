#! /usr/bin/env nextflow

println "\nI want to BLAST $params.query to $params.dbDir/$params.dbName using $params.threads CPUs and output it to $params.outdir\n"

def helpMessage() {
  log.info """
        Usage:
        The typical command for running the pipeline is as follows:
        nextflow run main.nf --query QUERY.fasta --dbDir "blastDatabaseDirectory" --dbName "blastPrefixName"

        Mandatory arguments:
         --query                        Query fasta file of sequences you wish to BLAST
         --dbDir                        BLAST database directory (full path required)
         --dbName                       Prefix name of the BLAST database

       Optional arguments:
        --outdir                       Output directory to place final BLAST output
        --outfmt                       Output format ['6']
        --options                      Additional options for BLAST command [-evalue 1e-3]
        --outFileName                  Prefix name for BLAST output [input.blastout]
        --threads                      Number of CPUs to use during blast job [16]
        --chunkSize                    Number of fasta records to use when splitting the query fasta file
        --app                          BLAST program to use [blastn;blastp,tblastn,blastx]
        --genome                       If specified with a genome fasta file, a BLAST database will be generated for the genome
        --help                         This usage statement.
        """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}


Channel
    .fromPath(params.query)
    .splitFasta(by: params.chunkSize, file:true)
    .set { queryFile_ch }



if (params.genome) {
  genomefile_ch = Channel
                  .fromPath(params.genome)
                  .map { file -> tuple(file.simpleName, file.parent, file) }

  process runMakeBlastDB {
    input:
    set val(dbName), path(dbDir), file(FILE) from genomefile_ch

    output:
    val dbName into dbName_ch
    path dbDir into dbDir_ch

    script:
    """
    makeblastdb -in ${params.genome} -dbtype 'nucl' -out $dbDir/$dbName
    makeblastdb -in ${params.genome} -dbtype 'prot' -out $dbDir/$dbName
    """
  }

} else {

Channel.fromPath(params.dbDir)
    .set { dbDir_ch }

Channel.from(params.dbName)
    .set { dbName_ch }
}

process runBlast {

  container = 'ncbi/blast'
  publishDir "${params.outdir}/blastout"

  input:
  path queryFile from queryFile_ch
  path dbDir from dbDir_ch.val
  val dbName from dbName_ch.val

  output:
  path(params.outFileName) into blast_output_ch

  script:
  """
  $params.app -num_threads $params.threads -db $dbDir/$dbName -query $queryFile -outfmt $params.outfmt $params.options -out $params.outFileName
  """
 
}


blast_output_ch
  .collectFile(name: 'blast_output_combined.txt', storeDir: params.outdir)
