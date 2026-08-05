## Helpers used by every chapter.
##
## The point of embed_file() is that no code block in this book is typed into the
## book.  Every one of them is read from a file in examples/ that actually runs,
## so the tutorial cannot drift away from working code.

.lang_for <- function(path) {
  base <- basename(path)
  if (base == "Snakefile") return("python")
  switch(tolower(tools::file_ext(path)),
         r = "r", rmd = "markdown", qmd = "markdown",
         yaml = "yaml", yml = "yaml",
         tex = "latex", sty = "latex", bib = "bibtex",
         py = "python", sh = "bash", csv = "default",
         "default")
}

#' Print a file as a fenced, syntax-highlighted code block
#'
#' @param path file to read, relative to the book root
#' @param lang language for highlighting; guessed from the extension if NULL
#' @param filename label shown above the block; defaults to `path` with the
#'   examples/<dir>/ prefix stripped, since that prefix is noise in the text
#' @param lines optional integer vector of line numbers to show
#' @param from,to regular expressions marking the first and last line of an
#'   excerpt, used instead of `lines`; anchoring an excerpt to the text it starts
#'   with means editing the example file cannot silently shift the excerpt
#' @param omit if TRUE and `lines` is given, mark the elision with a comment
embed_file <- function(path, lang = NULL, filename = NULL, lines = NULL,
                       from = NULL, to = NULL, omit = FALSE) {
  stopifnot(file.exists(path))
  txt <- readLines(path, warn = FALSE)
  if (!is.null(from) || !is.null(to)) {
    start <- if (is.null(from)) 1L else grep(from, txt)[1]
    if (is.na(start)) stop("pattern not found in ", path, ": ", from)
    rest <- if (is.null(to)) length(txt) else {
      hit <- grep(to, txt)
      hit <- hit[hit >= start][1]
      if (is.na(hit)) stop("pattern not found in ", path, ": ", to)
      hit
    }
    lines <- start:rest
  }
  if (!is.null(lines)) {
    keep <- txt[lines]
    if (omit) {
      comment <- if (identical(.lang_for(path), "r")) "## ..." else "# ..."
      keep <- c(if (min(lines) > 1) comment, keep,
                if (max(lines) < length(txt)) comment)
    }
    txt <- keep
  }
  if (is.null(lang)) lang <- .lang_for(path)
  if (is.null(filename)) filename <- sub("^examples/[^/]+/", "", path)
  cat(.fence(txt, sprintf('{.%s filename="%s"}', lang, filename)))
}

## A fenced block has to be delimited by more backticks than appear inside it,
## which matters when the file being shown is itself a .qmd
.fence <- function(txt, attrs) {
  inner <- regmatches(txt, regexpr("^`+", txt))
  n <- max(3L, nchar(c(inner, "")) + 1L)
  bar <- strrep("`", n)
  paste0(bar, attrs, "\n", paste(txt, collapse = "\n"), "\n", bar, "\n")
}

#' Print a stored terminal transcript
#'
#' Transcripts live in transcripts/ and are captured from real runs rather than
#' typed by hand, for the same reason as embed_file().
transcript <- function(name) {
  path <- file.path("transcripts", name)
  stopifnot(file.exists(path))
  cat(.fence(readLines(path, warn = FALSE), "bash"))
}
