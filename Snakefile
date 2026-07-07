RAW_DIR = "results/raw"
QC_DIR = "results/qc"
SRA_ID = "SRR1972739"
REF_ID = "AF086833.2"

rule all:
    input:
        f"{QC_DIR}/{SRA_ID}_fastqc.html"

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
