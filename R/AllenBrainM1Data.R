#' Obtain aggregated per-cell type single nuclei expression data from Allen Brain Map human primary motor cortex (snRNA-seq)
#'
#' Download and cache the 127 aggregated per-cell type normalized expression values of 76533 single nuclei RNA-seq samples
#' from the Allen Brain Map.
#'
#' @inheritParams HumanPrimaryCellAtlasData
#'
#' @details 
#' This function provides aggregated per-cell type expression profiles for 127 cell types derived from 76533 single nuclei 
#' RNA-seq from 2 human primary motor cortex specimens generated for the Allen Brain Map.
#'
#' The aggregate trimmed means data was downloaded from \url{https://portal.brain-map.org/atlases-and-data/rnaseq/human-m1-10x}.
#' 
#' The dataset contains 127 aggregate expression profiles annotated to 8 main cell types (\code{"label.main"}):
#' \itemize{
#'     \item Inhibitory Neurons
#'	   \item Excitatory Neurons
#'     \item Astrocytes
#'     \item Endothelial Cells 
#'     \item Microglial Cells
#'     \item Oligodendrocytes
#'     \item Oligodendrocyte Progenitor Cells
#'     \item Vascular and Leptomeningeal Cells
#' } 
#' These are split further into 127 subtypes (\code{"label.fine"}).
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
#' Bakken T et al. (2020).
#' Evolution of cellular diversity in primary motor cortex of human, marmoset monkey, and mouse.
#' \emph{bioRxiv.} 2020.03.31.016972; doi: https://doi.org/10.1101/2020.03.31.016972
#' 
#' @examples
#' ref.se <- AllenBrainM1Data()
#' 
#' @export
AllenBrainM1Data <- function(ensembl=FALSE, cell.ont=c("all", "nonna", "none")) {
    version <- "1.0.0"
    se <- .create_se("allen_m1", version, 
        assays="logcounts", rm.NA = "none",
        has.rowdata = FALSE, has.coldata = TRUE)

    se <- .convert_to_ensembl(se, "Hs", ensembl)
    se <- .add_ontology(se, "allen_m1", match.arg(cell.ont))

    se
}
