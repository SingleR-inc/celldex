#' List available references
#'
#' List the available reference datasets and the associated versions in \pkg{celldex}.
#'
#' @param name String containing the name of the reference dataset.
#'
#' @return 
#' For \code{listReferences}, a character vector containing the names of the available references.
#'
#' For \code{listVersions}, a character vector containing the names of the available versions of the \code{name} reference.
#'
#' For \code{fetchLatestVersion}, a string containing the name of the latest version.
#'
#' @author Aaron Lun
#'
#' @examples
#' listReferences()
#' listVersions("immgen")
#' fetchLatestVersion("immgen")
#'
#' @export
#' @importFrom gypsum listAssets
listReferences <- function() {
    listAssets("celldex")
}

#' @export
#' @rdname listReferences
listVersions <- function(name) {
    gypsum::listVersions("celldex", name)
}

#' @export
#' @rdname listReferences
#' @importFrom gypsum fetchLatest
fetchLatestVersion <- function(name) {
    fetchLatest("celldex", name)
}
