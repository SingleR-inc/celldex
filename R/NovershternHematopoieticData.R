#' Obtain bulk microarray expression for sorted hematopoietic cells 
#'
#' Download and cache the normalized expression values of 211 bulk human microarray samples
#' of sorted hematopoietic cell populations that can be found in 
#' \href{https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE24759}{GSE24759}.
#'
#' @inheritParams HumanPrimaryCellAtlasData
#'
#' @details 
#' The dataset contains 211 human microarray samples annotated to 16 main cell types (\code{"label.main"}):
#' \itemize{
#'     \item Basophils
#'     \item B cells
#'     \item CMPs
#'     \item Dendritic cells
#'     \item Eosinophils
#'     \item Erythroid cells
#'     \item GMPS
#'     \item Granulocytes
#'     \item HSCs
#'     \item Megakaryocytes
#'     \item MEPs
#'     \item Monocytes
#'     \item NK cells
#'     \item NK T cells
#'     \item CD8+ T cells
#'     \item CD4+ T cells
#' }
#'
#' Samples were additionally annotated to 38 fine cell types (\code{"label.fine"}):
#' \itemize{
#'     \item Basophils
#'     \item Naive B cells
#'     \item Mature B cells class able to switch
#'     \item Mature B cells
#'     \item Mature B cells class switched
#'     \item Common myeloid progenitors
#'     \item Plasmacytoid Dendritic Cells
#'     \item Myeloid Dendritic Cells
#'     \item Eosinophils
#'     \item Erythroid_CD34+ CD71+ GlyA-
#'     \item Erythroid_CD34- CD71+ GlyA-
#'     \item Erythroid_CD34- CD71+ GlyA+
#'     \item Erythroid_CD34- CD71lo GlyA+
#'     \item Erythroid_CD34- CD71- GlyA+
#'     \item Granulocyte/monocyte progenitors
#'     \item Colony Forming Unit-Granulocytes
#'     \item Granulocyte (Neutrophilic Metamyelocytes)
#'     \item Granulocyte (Neutrophils)
#'     \item Hematopoietic stem cells_CD133+ CD34dim
#'     \item Hematopoietic stem cell_CD38- CD34+
#'     \item Colony Forming Unit-Megakaryocytic
#'     \item Megakaryocytes
#'     \item Megakaryocyte/erythroid progenitors
#'     \item Colony Forming Unit-Monocytes
#'     \item Monocytes
#'     \item Mature NK cells_CD56- CD16+ CD3-
#'     \item Mature NK cells_CD56+ CD16+ CD3-
#'     \item Mature NK cells_CD56- CD16- CD3-
#'     \item NK T cells
#'     \item Early B cells
#'     \item Pro B cells
#'     \item CD8+ Effector Memory RA
#'     \item Naive CD8+ T cells
#'     \item CD8+ Effector Memory
#'     \item CD8+ Central Memory
#'     \item Naive CD4+ T cells
#'     \item CD4+ Effector Memory
#'     \item CD4+ Central Memory
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
#' Novershtern N et al. (2011).
#' Densely interconnected transcriptional circuits control cell states in human hematopoiesis.
#' \emph{Cell} 144, 296-309.
#' 
#' @examples
#' ref.se <- NovershternHematopoieticData()
#' 
#' @export
NovershternHematopoieticData <- function(ensembl=FALSE, cell.ont=c("all", "nonna", "none")) {
    se <- .create_se("dmap", 
        version = c(logcounts="1.0.0", coldata="1.2.0"), 
        assays="logcounts", rm.NA = "none",
        has.rowdata = FALSE, has.coldata = TRUE)

    se <- .convert_to_ensembl(se, "Hs", ensembl)
    se <- .add_ontology(se, "novershtern", match.arg(cell.ont))

    se
}
