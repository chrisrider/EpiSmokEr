#' @title
#' Epigenetic Smoking status Estimator
#'
#' @aliases EpiSmokEr
#'
#' @description
#' A function to estimate the smoking status based on the Illumina 450K methylation profiles generated from whole blood.
#' Estimation proceeds via one of the 4 methods (MultinomialLASSO (SSt), Elliott et al (SSc), Zhang et al (MS),
#' and a combination of all methods (all), as determined by the user.
#'
#' @param dataset
#' A data matrix of normalised methylation values in beta scale, with rows labelling the CpG probe ids and columns labelling the sample names.
#' In SSt missing methylation values are imputed as 0.5. In SSc and MS missing CpGs are excluded from the calculation.
#' eg: dummyBetaData
#'
#' @param samplesheet
#' A dataframe with samplenames as rownames. Must contain gender information as  "sex" column. sex column should be marked as 1 and 2
#' representing male and female respectively. Missing "sex" information is imputed as 0.
#' eg: dummySamplesheet
#'
#' @param ref.Elliott
#' This is used in "SSc" and "all" methods. It is a dataframe with 187 CpGs and the effect sizes used to calculate the smoking score
#' proposed by Elliott et al PMID: 24485148.
#'
#' @param ref.Zhang
#' This is used in "MS" and "all" methods. It is a dataframe with 4 CpGs and weights used to calculate methylation score proposed by Zhang et al PMID: 26826776.
#'
#' @param ref.CS
#' This is used in "SSt" and "all" methods. It is a dataframe with 121 CpGs selected by Multinomial LASSO approach, with log odd values for "CURRENT SMOKER" class.
#' In addition intercept term and sex coefficient terms are also provided by Multinomial LASSO approach.
#'
#' @param ref.FS
#' This is used in "SSt" and "all" methods. It is a dataframe with 121 CpGs selected by Multinomial LASSO approach, with log odd values for "FORMER SMOKER" class.
#' In addition intercept term and sex coefficient terms are also provided by Multinomial LASSO approach.
#'
#' @param ref.NS
#' This is used in "SSt" and "all" methods. It is a dataframe with 121 CpGs selected by Multinomial LASSO approach, with log odd values for "NEVER SMOKER" class.
#' In addition intercept term and sex coefficient terms are also provided by Multinomial LASSO approach.
#'
#' @param method
#' One of the four options as determined by the user ("MS","SSc", "SSt", "all")
#'
#' @return
#' Returns a result object with the methylaion score generated by MS, smoking score generated by SSc and predicted smoking probabilities and smoking status
#' labels generated from SSt method.
#'
#' @examples
#' data(dummyBetaData)
#' result <- epismoker(dataset = dummyBetaData, ref.Zhang = Zhangetal_cpgs, method = "MS")
#' ## result contains methylation score calculated using Zhang method-
#'
#' data(dummyBetaData)
#' result <- epismoker(dataset = dummyBetaData, ref.Elliott = Illig_data, method = "SSc")
#' ## result contains smoking score calculated using Elliott method-
#'
#' data(dummyBetaData)
#' samplesheet <- read.csv(system.file("extdata", "samplesheet_GSE42861.csv", package="EpiSmokEr"), header=TRUE, sep=",")
#' result <- epismoker(dataset = dummyBetaData, samplesheet = samplesheet, ref.CS = CS_final_coefs, ref.FS = FS_final_coefs, ref.NS = NS_final_coefs, method = "SSt")
#' ## result contains predicted smoking probabilities and smoking status labels calculated using Multinomial LASSO method (SSt).
#'
#' data(dummyBetaData)
##' result <- epismoker(dataset = dummyBetaData, samplesheet = samplesheet, ref.Elliott =  Illig_data, ref.Zhang = Zhangetal_cpgs,
#'                     ref.CS = CS_final_coefs, ref.FS = FS_final_coefs, ref.NS = NS_final_coefs, method = "all")
#' ## result contains smoking score from all the three methods
#' @export
#'
epismoker <- function(dataset, dataset_QN, dataset_ILM, dataset_SQN, samplesheet, ref.Elliott= Illig_data, ref.Zhang = Zhangetal_cpgs, ref.CS = CS_final_coefs, ref.FS = FS_final_coefs, ref.NS = NS_final_coefs, method = c("SSt","SSc", "MS", "all"))
{
  method <- match.arg(method)
  if (!method %in% c("SSt","SSc", "MS", "all"))
    stop(sprintf("(%s) is not a valid method!", method))
  if (method == "SSt") {
    result <- SSt(dataset, samplesheet, ref.CS, ref.FS, ref.NS)
  } else if (method == "SSc") {
    result <- SSc(dataset, ref.Elliott)
  } else if (method == "MS") {
    result <-MS(dataset, ref.Zhang)
  } else result <- all( dataset, dataset_QN, dataset_ILM, dataset_SQN, samplesheet, ref.Elliott,ref.Zhang,ref.CS,ref.FS,ref.NS)
  return(result)
}
