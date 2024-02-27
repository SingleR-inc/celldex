#' Fetch a reference dataset 
#'
#' Fetch a reference dataset (or its metadata) from the gypsum backend.
#'
#' @param name String containing the name of the reference dataset.
#' @param version String containing the version of the dataset.
#' @param path String containing the path to a subdataset, if \code{name} contains multiple reference datasets.
#' Defaults to \code{NA} if no subdatasets are present.
#' @param package String containing the name of the package.
#' @param cache,overwrite Arguments to pass to \code{\link[gypsum]{saveVersion}} or \code{\link[gypsum]{saveFile}}.
#' @param realize.assays Logical scalar indicating whether to realize assays into memory.
#' Dense and sparse \linkS4class{ReloadedArray} objects are converted into ordinary arrays and \linkS4class{dgCMatrix} objects, respectively.
#' @param ... Further arguments to pass to \code{\link{readObject}}.
#'
#' @return \code{fetchReference} returns the dataset as a \linkS4class{SummarizedExperiment}.
#' This is guaranteed to have a \code{"logcounts"} assay with log-normalized expression values,
#' along with at least one character vector of labels in the column data.
#'
#' \code{fetchMetadata} returns a named list of metadata for the specified dataset.
#'
#' @seealso
#' \url{https://github.com/ArtifactDB/bioconductor-metadata-index}, on the expected schema for the metadata.
#'
#' \code{\link{saveReference}} and \code{\link{uploadDirectory}}, to save and upload a dataset.
#'
#' \code{\link{listReferences}} and \code{\link{listVersions}}, to get possible values for \code{name} and \code{version}.
#' 
#' @author Aaron Lun
#' @examples
#' fetchReference("immgen", "2024-02-26")
#' str(fetchMetadata("immgen", "2024-02-26"))
#'
#' @export
#' @importFrom gypsum cacheDirectory saveVersion
#' @importFrom alabaster.base altReadObjectFunction altReadObject
fetchReference <- function(name, version, path=NA, package="celldex", cache=cacheDirectory(), overwrite=FALSE, realize.assays=FALSE, ...) {
    version_path <- saveVersion(package, name, version, cache=cache, overwrite=overwrite)

    obj_path <- version_path
    if (!is.na(path)) {
        obj_path <- file.path(version_path, gsub("/*$", "", path))
    }

    old <- altReadObjectFunction(cdLoadObject)
    on.exit(altReadObjectFunction(old))
    altReadObject(obj_path, celldex.realize.assays=realize.assays, ...)
}

#' @export
#' @rdname fetchReference
#' @importFrom jsonlite fromJSON
#' @importFrom gypsum cacheDirectory saveFile
fetchMetadata <- function(name, version, path=NA, package="celldex", cache=cacheDirectory(), overwrite=FALSE) {
    remote_path <- "_bioconductor.json"
    if (!is.na(path)) {
        remote_path <- paste0(path, "/", remote_path)
    }

    local_path <- saveFile(package, name, version, remote_path, cache=cache, overwrite=overwrite)
    fromJSON(local_path, simplifyVector=FALSE)
}

#' @import methods
#' @importFrom alabaster.base readObjectFile readObject
#' @importFrom SummarizedExperiment assay assay<-
cdLoadObject <- function(path, metadata=NULL, celldex.realize.assays=FALSE, ...) {
    if (is.null(metadata)) {
        metadata <- readObjectFile(path)
    }
    ans <- readObject(
        path, 
        metadata=metadata, 
        celldex.realize.assays=celldex.realize.assays, 
        ...
    )

    if (is(ans, "SummarizedExperiment")) {
        if (celldex.realize.assays) {
            for (y in assayNames(ans)) {
                assay(ans, y, withDimnames=FALSE) <- realize_array(assay(ans, y, withDimnames=FALSE))
            }
        }
    }

    ans
}

#' @import methods
#' @importClassesFrom alabaster.matrix ReloadedArray
#' @importFrom DelayedArray is_sparse type
#' @importClassesFrom Matrix lgCMatrix dgCMatrix
realize_array <- function(x) {
    if (is(x, "ReloadedArray")) {
        if (is_sparse(x)) {
            if (type(x) == "logical") {
                x <- as(x, "lgCMatrix")
            } else {
                x <- as(x, "dgCMatrix")
            }
        } else {
            x <- as.array(x)
        }
    }
    x
}
