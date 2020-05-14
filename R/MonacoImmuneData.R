#' Obtain bulk RNA-seq data of sorted human immune cells
#'
#' Download and cache the normalized expression values of 114 bulk RNA-seq samples
#' of sorted immune cell populations that can be found in 
#' \href{https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE107011}{GSE107011}.
#'
#' @inheritParams HumanPrimaryCellAtlasData
#'
#' @details 
#' The dataset contains 114 human RNA-seq samples annotated to 10 main cell types (\code{"label.main"}):
#' \itemize{
#'     \item CD8+ T cells
#'     \item T cells
#'     \item CD4+ T cells
#'     \item Progenitors
#'     \item B cells
#'     \item Monocytes
#'     \item NK cells
#'     \item Dendritic cells
#'     \item Neutrophils
#'     \item Basophils
#' }
#'
#' Samples were additionally annotated to 29 fine cell types (\code{"label.fine"}):
#' \itemize{
#'     \item Naive CD8 T cells
#'     \item Central memory CD8 T cells
#'     \item Effector memory CD8 T cells
#'     \item Terminal effector CD8 T cells
#'     \item MAIT cells
#'     \item Vd2 gd T cells
#'     \item Non-Vd2 gd T cells
#'     \item Follicular helper T cells
#'     \item T regulatory cells
#'     \item Th1 cells
#'     \item Th1/Th17 cells
#'     \item Th17 cells
#'     \item Th2 cells
#'     \item Naive CD4 T cells
#'     \item Terminal effector CD4 T cells
#'     \item Progenitor cells
#'     \item Naive B cells
#'     \item Non-switched memory B cells
#'     \item Exhausted B cells
#'     \item Switched memory B cells
#'     \item Plasmablasts
#'     \item Classical monocytes
#'     \item Intermediate monocytes
#'     \item Non classical monocytes
#'     \item Natural killer cells
#'     \item Plasmacytoid dendritic cells
#'     \item Myeloid dendritic cells
#'     \item Low-density neutrophils
#'     \item Low-density basophils
#' }
#' The subtypes have also been mapped to the Cell Ontology (\code{"label.ont"},
#' if \code{cell.ont} is not \code{"none"}), which can be used for further programmatic
#' queries.
#'
#' @return A \linkS4class{SummarizedExperiment} object with a \code{"logcounts"} assay
#' containing the log-normalized expression values, along with cell type labels in the 
#' \code{\link{colData}}.
#'
#' @author Jared Andrews
#' 
#' @references
#' Monaco G et al. (2019).
#' RNA-Seq Signatures Normalized by mRNA Abundance Allow Absolute Deconvolution of Human Immune Cell Types
#' \emph{Cell Rep.} 26, 1627-1640.
#' 
#' @examples
#' ref.se <- MonacoImmuneData()
#' 
#' @export
MonacoImmuneData <- function(ensembl=FALSE, cell.ont=c("all", "nonna", "none")) {
    version <- "1.0.0"
    se <- .create_se("monaco_immune", version, 
        assays="logcounts", rm.NA = "none",
        has.rowdata = FALSE, has.coldata = TRUE)

    se <- .convert_to_ensembl(se, "Hs", ensembl)
    se <- .add_ontology(se, "monaco", match.arg(cell.ont))

    se
}
