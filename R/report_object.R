

#' Create an object containing information for sdc report
#'
#' @slot intialObj sdcmicroOrNULL.
#' @slot finalObj sdcmicroOrNULL.
#' @slot unit characterOrNULL.
#' @slot hierarchy characterOrNULL.
#' @slot globalRisk logicalOrNULL.
#' @slot indRisk logicalOrNULL.
#' @slot sudaRisk logicalOrNULL.
#' @slot hierRisk logicalOrNULL.
#' @return
#' @import sdcMicro
#' @importClassesFrom sdcMicro  sdcMicroObj
#' @importFrom  dplyr %>% distinct
#' @export
#'
#' @examples


setClassUnion("dataframeOrNULL", c("data.frame", "NULL"))
setClassUnion("numericOrNULL", c("numeric", "NULL"))
setClassUnion("characterOrNULL", c("character", "NULL"))
setClassUnion("logicalOrNULL", c("logical", "NULL"))
setClassUnion("matrixOrNULL", c("matrix", "NULL"))
setClassUnion("listOrNULL", c("list", "NULL"))
setClassUnion("factorOrNULL", c("factor", "NULL"))
setClassUnion("logicalOrNULL", c("logical", "NULL"))
setClassUnion("sdcmicroOrNULL", c("sdcMicroObj","NULL"))
setClassUnion("sdcReportObjOrNULL", c("NULL"))

setClass("sdcReportObj",
         representation = representation(
           intialObj="sdcmicroOrNULL",
           finalObj="sdcmicroOrNULL",
           unit="characterOrNULL",
           hierarchy="characterOrNULL",
           global="logicalOrNULL",
           individual="logicalOrNULL",
           suda="logicalOrNULL",
           hierarchical="logicalOrNULL"
         ),
         prototype = prototype(
           intialObj=NULL,
           finalObj=NULL,
           unit=NULL,
           hierarchy=NULL,
           global=TRUE,
           individual=TRUE,
           suda=FALSE,
           hierarchical=FALSE
         )         )

setIs("sdcReportObj", "sdcReportObjOrNULL")


#' Title
#'
#' @param intialObj
#' @param finalObj
#' @param unit
#' @param hierarchy
#' @param global
#' @param individual
#' @param suda
#' @param hierarchical
#' @param childName
#'
#' @return
#' @importFrom methods new
#' @export
#'
#' @examples
saveReprtObj <- function(agrisvy,
                      intialObj=NULL,
                      finalObj    =NULL,
                      unit        =NULL,
                      hierarchy   =NULL,
                      global      =TRUE,
                      individual  =TRUE,
                      suda        =FALSE,
                      hierarchical=FALSE,
                      childName   =NULL) {

            obj <- new("sdcReportObj")

if (!is.null(intialObj)) obj@intialObj   <- intialObj
if (!is.null(finalObj)) obj@finalObj     <- finalObj
if (!is.null(unit)) obj@unit             <- unit
if (!is.null(hierarchy)) obj@hierarchy   <- hierarchy
if (!is.null(global)) obj@global         <- global
if (!is.null(individual)) obj@individual <- individual
if (!is.null(individual)) obj@individual <- individual
if (!is.null(suda)) obj@suda             <- suda


saveRDS(obj,glue("{agrisvy@workingDir}/{anoreportDir(agrisvy)}/child_{childName}.rds"))

file <- file.path(agrisvy@workingDir,anoreportDir(agrisvy),glue::glue("child_{childName}.rmd"))
file.create(file)
fileConn<-file(file)

if(agrisvy@language=="en"){
  template_rpt_child=system.file("txt_template","sdc_report_child.txt",package = "agrisvyr")
}

if(agrisvy@language=="fr"){
  template_rpt_child=system.file("txt_template","sdc_report_child_fr.txt",package = "agrisvyr")
}
writeLines(c(glue::glue(paste(readLines(template_rpt_child),
                              collapse = "\n"),.open = "{{",.close = "}}"))
           ,
           fileConn)
close(fileConn)
#---------------------------------

rpt_file=file.path(agrisvy@workingDir,anoreportDir(agrisvy),"sdc_report.rmd")

sdc_rpt=readLines(rpt_file)
appended=grep(glue::glue("child_{childName}.rmd"),sdc_rpt)


if(length(appended)!=0){
  sdc_rpt=sdc_rpt[-c((appended-1):(appended+2))]
}

if (agrisvy@language=="en"){

ind=grep("# Other anonymization measures of",sdc_rpt)
}

if (agrisvy@language=="fr"){
  ind=grep("# Autres mesures d'anonymisation",sdc_rpt)
}

before=sdc_rpt[1:(ind-1)]

after=sdc_rpt[ind:length(sdc_rpt)]

new_sdc_rpt=c(before,
              "",
              glue::glue("```{r,child='child_{{childName}}.rmd'}",.open = "{{",.close = "}}"),"```","",
              after)


fileConn<-file(rpt_file)
writeLines(new_sdc_rpt,fileConn)
close(fileConn)



}


#' Title
#'
#' @param sdc an object of type SdcMicroObj
#' @param df if the function return a dataframe or styled datafram for rmarkdown display
#' @param title title of the table in case df=FALSE
#'
#' @return
#' @import sdcMicro
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling column_spec
#' @importFrom dplyr  %>%
#' @export
#'
#' @examples

GlobRiskTab=function(sdc,df=FALSE,time,obj) {
# TODO: ameliorate
  title=paste0(time," global disclosure risk")

  res=rbind(
    data.frame(
      `Risk type`="Global risk",
      Value=paste0(round(100 * sdc@risk$global$risk, 2), "%")
    ),
    data.frame(`Risk type`="Expect. num. re.", Value=paste0(round( sdc@risk$global$risk_ER, 2)))
  )%>%
    #formating the table
    kableExtra::kbl(align='rc',caption=title,booktabs = T) %>%
    kableExtra::kable_classic_2(full_width = F) %>%
    kableExtra::column_spec(1, width = "12em", bold = T, border_right = T) %>%
    kableExtra::column_spec(2, width = "8em") %>%
    # kable_styling(position = "float_right") %>%
    kableExtra::kable_styling(latex_options = "HOLD_position")

  if(df){
    res=rbind(
      data.frame(
        `Risk type`="Global risk",
        Value=paste0(round(100 * sdc@risk$global$risk, 2), "%")
      ),
      data.frame(`Risk type`="Expect. num. re.", Value=paste0(round( sdc@risk$global$risk_ER, 2)))
    )
  }

  return(res)
}


setGeneric("RenderGlobalRisk", function(obj,time="initial") standardGeneric("RenderGlobalRisk"))

#' render global risk summary in Rmarkdown
#'
#' @param sdcReportObj
#'
#' @return
#' @import sdcMicro
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom dplyr  %>%
#' @export
#'
#' @examples
setMethod("RenderGlobalRisk",signature = "sdcReportObj",
          definition = function(obj,time="initial"){

      if (time=="initial") sdcObj=obj@intialObj
      if (time=="final") sdcObj=obj@finalObj


      GlobRiskTab(sdcObj,df=FALSE,time,obj)

          })

#' data frame containing k-anonymity information
#'
#' @param sdcObj an sdcMicro object
#' @param df logical. retunrn a dataframe or a styled dataframe
#' @param levels k-anonymity levels
#' @param title title of the table in case df=FALSE
#'
#' @return
#' @import sdcMicro
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom dplyr %>%
#' @export
#'
#' @examples

KanoTab=function(sdcObj,df=FALSE,levels=c(2,3,5),time,obj) {

  title=paste0(time," k-anonymity")

  KanoRow=function(k) {

    data.frame(`Level of k anonymity`=k,
               fk=paste0(sum((sdcObj@risk$individual[, "fk"]) < k),
                         " (", 100 * round(sum((sdcObj@risk$individual[, "fk"]) < k)/nrow(sdcObj@origData), 4), "%)"))
  }

  res=do.call("rbind",lapply(levels,KanoRow)) %>%
    kableExtra::kbl(caption = title) %>%
    kableExtra::kable_classic_2(full_width = F) %>%
    kableExtra::kable_styling(latex_options = "HOLD_position")

  if(df){
    res=as.data.frame(do.call("rbind",lapply(levels,KanoRow)))
  }
  return(res)
}


setGeneric("renderKanoTab",function(obj,levels=c(2,3,5),time="initial") standardGeneric("renderKanoTab"))

#' render k-anonymity table in rmarkdown
#'
#' @param sdcReportObj
#'
#' @return
#' a dtaframe
#'
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom  dplyr %>%
#' @export
#'
#' @examples
setMethod("renderKanoTab",signature = "sdcReportObj",
          definition = function(obj,levels=c(2,3,5),time="initial") {

            if (time=="initial") sdcObj=obj@intialObj
            if (time=="final") sdcObj=obj@finalObj

            KanoTab(sdcObj,df=FALSE,levels = levels,time,obj)
          })


#' a  dataframe containing the summary of individual risk
#'
#' @param sdc an sdcMicro Object
#' @param df retunrn a simple dataframe or a styled dataframe
#' @param title title of the styled dataframe
#'
#' @return
#' a dataframe
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom dplyr %>%
#' @importFrom stats median quantile
#' @export
#' @examples
RiskIndSUmmary=function(sdc,df=FALSE,time,obj){
  title=paste0("Summary of the", time, "individual risk")


  res=rbind(
    data.frame(Indicator="Mean",Value=paste0(round(mean(sdc@risk$individual[, "risk"]),4)*100,"%")),
    data.frame(Indicator="Min",Value=paste0(round(min(sdc@risk$individual[, "risk"]),4),"%")),
    data.frame(Indicator="1st quartile",Value=paste0(round(quantile(sdc@risk$individual[, "risk"],0.25),4)*100,"%")),
    data.frame(Indicator="Median",Value=paste0(round(median(sdc@risk$individual[, "risk"]),4)*100,"%")),
    data.frame(Indicator="3rd quartile",Value=paste0(round(quantile(sdc@risk$individual[, "risk"],0.75)*100,4),"%")),
    data.frame(Indicator="Max",Value=paste0(round(max(sdc@risk$individual[, "risk"]),4)*100,"%"))

  ) %>% kableExtra::kbl(caption=title,booktabs=TRUE) %>%
    kableExtra::kable_classic_2(full_width = F) %>%
    kableExtra::kable_styling(latex_options = "HOLD_position")

  if(df){

    res=rbind(
      data.frame(Indicator="Mean",Value=paste0(round(mean(sdc@risk$individual[, "risk"]),4)*100,"%")),
      data.frame(Indicator="Min",Value=paste0(round(min(sdc@risk$individual[, "risk"]),4),"%")),
      data.frame(Indicator="1st quartile",Value=paste0(round(quantile(sdc@risk$individual[, "risk"],0.25),4)*100,"%")),
      data.frame(Indicator="Median",Value=paste0(round(median(sdc@risk$individual[, "risk"]),4)*100,"%")),
      data.frame(Indicator="3rd quartile",Value=paste0(round(quantile(sdc@risk$individual[, "risk"],0.75)*100,4),"%")),
      data.frame(Indicator="Max",Value=paste0(round(max(sdc@risk$individual[, "risk"]),4)*100,"%"))

    )
  }

  return(res)
}


setGeneric("renderRiskIndSUmmary",function(obj,time="initial") standardGeneric("renderRiskIndSUmmary"))

#' render summary of individual risk
#'
#' @param sdcReportObj
#'
#' @return
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
setMethod("renderRiskIndSUmmary",signature = "sdcReportObj",
          definition = function(obj,time = "initial") {

            if (time == "initial") sdcObj = obj@intialObj
            if (time == "final") sdcObj = obj@finalObj

            RiskIndSUmmary(sdcObj,df = FALSE,time,obj)
          })



#' summary of hierarchical risk
#'
#' @param sdc an sdcMicro Object
#' @param dfl return a simple dataframe or a styled dataframe
#' @param title title of the styled dataframe
#'
#' @return
#' a data frame
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom dplyr %>% distinct
#' @import sdcMicro
#' @export
#'
#' @examples
HierRiskSummary=function(sdc,dfl=FALSE,time,obj){

  title=paste0("Summary of the",time, "hierarchical risk")
  df=cbind(data.frame(sdc@origData[,sdc@hhId]),
           data.frame(sdc@risk$individual[,"hier_risk"]))
  names(df)=c("hier_id","risk")
  df=df %>% dplyr::distinct(.data$hier_id,.data$risk)
  res=rbind(
    data.frame(Indicator="Mean",Value=paste0(round(mean(df[, "risk"]),4)*100,"%")),
    data.frame(Indicator="Min",Value=paste0(round(min(df[, "risk"]),4),"%")),
    data.frame(Indicator="1st quartile",Value=paste0(round(quantile(df[, "risk"],0.25),4)*100,"%")),
    data.frame(Indicator="Median",Value=paste0(round(median(df[, "risk"]),4)*100,"%")),
    data.frame(Indicator="3rd quartile",Value=paste0(round(quantile(df[, "risk"],0.75)*100,4),"%")),
    data.frame(Indicator="Max",Value=paste0(round(max(df[, "risk"]),4)*100,"%"))

  ) %>% kableExtra::kbl(caption=title,booktabs=TRUE) %>%
    kableExtra::kable_classic_2(full_width = F) %>%
    kableExtra::kable_styling(latex_options = "HOLD_position")

  if(dfl){

    res=rbind(
      data.frame(Indicator="Mean",Value=paste0(round(mean(df[, "risk"]),4)*100,"%")),
      data.frame(Indicator="Min",Value=paste0(round(min(df[, "risk"]),4),"%")),
      data.frame(Indicator="1st quartile",Value=paste0(round(quantile(df[, "risk"],0.25),4)*100,"%")),
      data.frame(Indicator="Median",Value=paste0(round(median(df[, "risk"]),4)*100,"%")),
      data.frame(Indicator="3rd quartile",Value=paste0(round(quantile(df[, "risk"],0.75)*100,4),"%")),
      data.frame(Indicator="Max",Value=paste0(round(max(df[, "risk"]),4)*100,"%"))

    )
  }
  return(res)
}

setGeneric("renderHierRiskSummary",function(obj,time="initial") standardGeneric("renderHierRiskSummary"))

#' render hierarchical risk summary
#'
#' @param sdcReportObj
#'
#' @return
#' a dataframe
#'
#' @import knitr
#' @importFrom   kableExtra kbl kable_classic_2 kable_styling
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
setMethod("renderHierRiskSummary",signature = "sdcReportObj",
          definition = function(obj,time="initial"){

            if (time == "initial") sdcObj = obj@intialObj
            if (time == "final") sdcObj = obj@finalObj

            HierRiskSummary(sdcObj,dfl = FALSE,time, obj)
          })
