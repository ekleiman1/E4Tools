#' Extras: Make EDA bins
#'
#' Put EDA data in bins of X minutes length
#' @param participant_list list of participant numbers NOTE: This should match the names of the folders (e.g., participant 1001's data should be in a folder called "1001")
#' @param rdslocation.EDA folder location where raw EDA (from part 1) is saved.
#' @param rdslocation.binnedEDA folder location where you want the RDS outputs to go (make sure that it ends in /)
#' @param BinLengthMin folder location where you want the RDS outputs to go (make sure that it ends in /)
#' @param RejectFlag Did you include in step 1 the option to keep the flag that shows which data the high and low pass filters rejected (By default, these are included in step 1) AND do you want to include a summary in this dataset of how many samples in a bin were rejected? If you want to run the diagnostic steps, you must keep this. Defaults to TRUE.
#' @keywords acc
#' @export
#' @examples
#' \dontrun{XXX}


E4.extras.BinEDA<-function(participant_list,rdslocation.EDA,rdslocation.binnedEDA,BinLengthMin,RejectFlag=T){
###open data
  for (NUMB in participant_list) {
    message(paste("Starting participant",NUMB))

  BinData<-readRDS(paste(rdslocation.EDA,NUMB,"_EDA.rds",sep=""))


##calculate metrics for bin sizes
BinLengthSamples<-(4*60*BinLengthMin)
tot_bins<-round(nrow(BinData)/BinLengthSamples)

###make bin numbers
BinData$bin<-rep(1:tot_bins,each=BinLengthSamples,length.out=nrow(BinData))

### aggregate across bins
BinnedEDA<-stats::aggregate(cbind(EDA_raw,EDA_HighLowPass,EDA_FeatureScaled,EDA_filtered,EDA_FeatureScaled_Filtered)~(bin),data=BinData,FUN="mean")
BinnedTS<-stats::aggregate(ts~(bin),data=BinData,FUN="min")
if(RejectFlag==T){BinnedReject<-stats::aggregate(EDA_reject~(bin),data=BinData,FUN="sum")}
BinnedSerial<-stats::aggregate(E4_serial~(bin),data=BinData,FUN="max")

##merge into one file
Binned_Merged<-merge(BinnedTS,BinnedEDA,by="bin")
if(RejectFlag==T){Binned_Merged<-merge(Binned_Merged,BinnedReject,by="bin")}
Binned_Merged<-merge(Binned_Merged,BinnedSerial,by="bin")
Binned_Merged$NUMB<-NUMB

###save
if(!dir.exists(rdslocation.binnedEDA)==T){dir.create(rdslocation.binnedEDA,recursive=T)}
filename<-paste(rdslocation.binnedEDA,NUMB,"_binnedEDA.rds",sep="")
saveRDS(Binned_Merged,file=filename)
}
}
