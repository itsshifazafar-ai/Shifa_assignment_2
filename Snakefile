RAW_DIR = "results/raw"
QC_DIR = "results/qc"
ALIGNED_DIR = "results/aligned"
SRA_ID = "SRR1972739"
REF_ID = "AF086833.2"

rule all:
    input:
        f"{QC_DIR}/{SRA_ID}_fastqc.html",
        f"{ALIGNED_DIR}/aligned.sam"

rule download_data:
    output:
        ref=f"{RAW_DIR}/reference.fasta",
        fastq=f"{RAW_DIR}/{SRA_ID}.fastq"
    shell:
        """
        mkdir -p {RAW_DIR}
        efetch -db nucleotide -id {REF_ID} -format fasta > {output.ref} || true
        prefetch {SRA_ID} -O {RAW_DIR}
        fastq-dump -X 10000 --outdir {RAW_DIR} {RAW_DIR}/{SRA_ID}/{SRA_ID}.sra
        """

rule fastqc:
    input:
        f"{RAW_DIR}/{SRA_ID}.fastq"
    output:
        f"{QC_DIR}/{SRA_ID}_fastqc.html"
    shell:
        """
        mkdir -p {QC_DIR}
        fastqc {input} -o {QC_DIR}
        """

rule index_reference:
    input:
        f"{RAW_DIR}/reference.fasta"
    output:
        f"{RAW_DIR}/reference.fasta.bwt"
    shell:
        """
        bwa index {input}
        """

rule align_reads:
    input:
        ref=f"{RAW_DIR}/reference.fasta",
        reads=f"{RAW_DIR}/{SRA_ID}.fastq",
        index=f"{RAW_DIR}/reference.fasta.bwt"
    output:
        f"{ALIGNED_DIR}/aligned.sam"
    shell:
        """
        mkdir -p {ALIGNED_DIR}
        bwa mem {input.ref} {input.reads} > {output}
        """
