#' @title
#' Methylation score (MS) calculation using Zhang Method.
#'
#' @description
#' Estimates methylation score (MS) using Zhang et al Method.
#'
#' @param dataset
#' A data matrix of normalised methylation values in beta scale, with rows labelling the CpG probe ids and columns labelling the sample names.
#' Missing CpGs are excluded from the methylation score calculation.
#' eg: dummyBetaData
#'
#' @param ref.Zhang
#' This is used in "MS" and "all" methods. It is a dataframe with 4 CpGs and weights used to calculate methylation score proposed by Zhang et al PMID: 26826776.
#'
#' @return
#' Returns a result object with smoking score generated by following approach outlined in Zhang et al PMID: 26826776.
#'
#' @examples
#' data(dummyBetaData)
#' result <- epismoker(dataset = dummyBetaData, ref.Zhang = Zhangetal_cpgs, method = "MS")
#' ## result contains methylation score calculated from Zhang et al.
#' @export
#'
MS <- function(dataset, ref.Zhang = Zhangetal_cpgs){
  message("================================")
  message("<<<<< Methylation Score Calculation Started >>>>>")
  message("=================================")
  dataset_MS <- dataset
  cpgs <- intersect(rownames(dataset_MS) , names(ref.Zhang))
  message(sprintf("Dataset has %s of %s CpGs required for Zhang et al method",length(cpgs),length(ref.Zhang)))
  dataset_MS <- dataset_MS[cpgs,]
  ref.Zhang <- ref.Zhang[cpgs]
  # check if the order colnames of dataset equal to names(weights)
  stopifnot(rownames(dataset_MS) == names(ref.Zhang))
  res_MS <- setNames(data.frame(colnames(dataset_MS),apply(dataset_MS,2,SmokingScore, ref.Zhang)), c("SampleName","methylationScore"))
  rm(dataset_MS)
  message("==================================")
  message("<<<<< Methylation Score Calculation Completed >>>>>")
  message("==================================")
  return(data.frame(res_MS))
}

SmokingScore <- function(betas, weights) {sum(t(betas) %*% weights)}
