#' Obtain mouse bulk expression data of sorted cell populations (RNA-seq)
#'
#' Download and cache the normalized expression values of 358 bulk RNA-seq samples
#' of sorted cell populations that can be found at GEO.
#'
#' @inheritParams HumanPrimaryCellAtlasData
#'
#' @details This dataset was contributed by the Benayoun Lab that identified, 
#' downloaded and processed data sets on GEO that corresponded to sorted cell
#' types (Benayoun et al., 2019).
#' 
#' The dataset contains 358 mouse RNA-seq samples annotated to 18 main cell types (\code{"label.main"}):
#' \itemize{
#'     \item Adipocytes
#'     \item Astrocytes
#'     \item B cells 
#'     \item Cardiomyocytes
#'     \item Dendritic cells
#'     \item Endothelial cells
#'     \item Epithelial cells
#'     \item Erythrocytes
#'     \item Fibroblasts
#'     \item Granulocytes
#'     \item Hepatocytes
#'     \item Macrophages
#'     \item Microglia
#'     \item Monocytes
#'     \item Neurons
#'     \item NK cells
#'     \item Oligodendrocytes
#'     \item T cells
#' } 
#' These are split further into 28 subtypes (\code{"label.fine"}).
#' The subtypes have also been mapped to the Cell Ontology (\code{"label.ont"},
#' if \code{cell.ont} is not \code{"none"}), which can be used for further programmatic
#' queries.
#'
#' @return A \linkS4class{SummarizedExperiment} object with a \code{"logcounts"} assay
#' containing the log-normalized expression values, along with cell type labels in the 
#' \code{\link{colData}}.
#'
#' @author Friederike Dündar
#' 
#' @references
#' Benayoun B et al. (2019).
#' Remodeling of epigenome and transcriptome landscapes with aging in mice reveals widespread induction of inflammatory responses.
#' \emph{Genome Res.} 29, 697-709.
#' 
#' Code at \url{https://github.com/BenayounLaboratory/Mouse_Aging_Epigenomics_2018/tree/master/FigureS7_CIBERSORT/RNAseq_datasets_for_Deconvolution/2017-01-18}
#' 
#' @examples
#' ref.se <- MouseRNAseqData()
#' 
#' @export
MouseRNAseqData <- function(ensembl=FALSE, cell.ont=c("all", "nonna", "none"), legacy=FALSE) {
    cell.ont <- match.arg(cell.ont)

    if (!legacy && cell.ont == "all") {
        se <- fetchReference("mouse_rnaseq", "2024-02-26", realize.assays=TRUE)
    } else {
        version <- "1.0.0"
        se <- .create_se("mouse.rnaseq", version, 
            assays="logcounts", rm.NA = "none",
            has.rowdata = FALSE, has.coldata = TRUE)
        se <- .add_ontology(se, "mouse_rnaseq", cell.ont)
    }

    .convert_to_ensembl(se, "Mm", ensembl)
}
