#' Save a reference dataset 
#'
#' Save a reference dataset to disk, usually in preparation for upload via \code{\link{uploadDirectory}}.
#'
#' @param x Matrix of log-normalized expression values.
#' This may be sparse or dense, but should be non-integer and have no missing values.
#' Row names should be present and unique for all rows.
#' @param labels \linkS4class{DataFrame} of labels.
#' Each row of \code{labels} corresponds to a column of \code{x} and contains the label(s) for that column.
#' Each column of \code{labels} represents a different label type;
#' typically, the column name has a \code{label.} prefix to distinguish between, e.g., \code{label.fine}, \code{label.broad} and so on.
#' At least one column should be present.
#' @param path String containing the path to a directory in which to save \code{x}.
#' @param metadata Named list containing metadata for this reference dataset,
#' see the schema returned by \code{\link{fetchMetadataSchema}()}.
#' Note that the \code{applications.takane} property will be automatically added by this function and does not have to be supplied.
#'
#' @return \code{x} and \code{labels} are used to create a \linkS4class{SummarizedExperiment} that is saved into \code{path}.
#' \code{NULL} is invisibly returned.
#'
#' @details
#' The SummarizedExperiment saved to \code{path} is guaranteed to have the \code{"logcounts"} assay and at least one column in \code{labels}.
#' This mirrors the expectation for reference datasets obtained via \code{\link{fetchReference}}.
#'
#' @author Aaron Lun
#' @examples
#' # Mocking up some data to be saved.
#' x <- matrix(rnorm(1000), ncol=10)
#' rownames(x) <- sprintf("GENE_%i", seq_len(nrow(x)))
#' labels <- DataFrame(
#'     labels.broad = sample(c("B", "T", "NK"), ncol(x), replace=TRUE),
#'     labels.fine = sample(c("PC", "pre-B", "pro-B", "Th2", "CD4+T", "NK"), 
#'         ncol(x), replace=TRUE)
#' )
#'
#' # Making up some metadata as well.
#' meta <- list(
#'     title="New reference dataset",
#'     description="This is a new reference dataset, generated from blah blah.",
#'     genome="GRCm38",
#'     taxonomy_id="10090",
#'     sources=list(
#'         list(provider="GEO", id="GSE123456"),
#'         list(provider="PubMed", id="123456"),
#'         list(provider="URL", id="https://reference.data.com", version="2024-02-26")
#'     ),
#'     maintainer_name="Chihaya Kisaragi",
#'     maintainer_email="kisaragi.chihaya@765.com"
#' )
#' 
#' # Actually saving it.
#' tmp <- tempfile()
#' saveReference(x, labels, tmp, meta)
#'
#' # Reloading it to make sure it looks good.
#' alabaster.base::readObject(tmp)
#' str(jsonlite::fromJSON(file.path(tmp, "_bioconductor.json")))
#'
#' @seealso
#' \code{\link{uploadDirectory}}, to upload the saved dataset to the gypsum backend.
#'
#' \code{\link{fetchReference}}, to download an existing dataset into the current sesssion.
#'
#' @export
#' @importFrom alabaster.base saveObject
#' @importMethodsFrom alabaster.se saveObject
#' @importFrom DelayedArray type
#' @importFrom SummarizedExperiment SummarizedExperiment assay<-
#' @importFrom gypsum fetchMetadataSchema validateMetadata
#' @importFrom jsonlite toJSON 
saveReference <- function(x, labels, path, metadata) {
    schema <- fetchMetadataSchema()
    if (is.null(metadata$bioconductor_version)) {
        metadata$bioconductor_version <- as.character(BiocManager::version())
    }
    metadata$taxonomy_id <- I(metadata$taxonomy_id)
    metadata$genome <- I(metadata$genome)
    validateMetadata(metadata, schema) # First validation for user-supplied content.

    # Check that all labels are categorical.
    if (ncol(labels) == 0L) {
        stop("'labels' should contain at least one column")
    }
    for (cn in colnames(labels)) {
        if (!is.character(labels[[cn]])) {
            stop("all columns of 'labels' should be character vectors")
        }
    }

    # Checking the assay data.
    if (type(x) != "double" || all(x %% 1 == 0)) {
        stop("'x' should contain log-normalized expression values")
    }
    if (anyNA(x)) {
        stop("detected missing values in 'x'")
    }
    rnms  <- rownames(x)
    if (is.null(rnms) && anyDuplicated(rnms)) {
        stop("'x' should have unique row names")
    }

    se <- SummarizedExperiment(list(logcounts=x), colData=labels)
    assay(se, withDimnames=FALSE) <- unname(x)
    unlink(path, recursive=TRUE)
    saveObject(se, path, ReloadedArray.reuse.files="symlink")

    # Attach some takane metadata to it.
    takane <- list(type = "summarized_experiment")
    takane$summarized_experiment = list(
       rows = nrow(se),
       columns = ncol(se),
       assays = I(assayNames(se)),
       column_annotations = I(colnames(colData(se)))
    )
    metadata$applications <- c(metadata$applications, list(takane=takane))

    # Second validation with the takane metadata.
    contents <- toJSON(metadata, pretty=4, auto_unbox=TRUE)
    validateMetadata(contents, schema=schema)
    write(contents, file=file.path(path, "_bioconductor.json"))
    invisible(NULL)
}
