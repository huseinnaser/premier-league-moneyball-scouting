#######################################
# SIMPLE PLAYER SCORING (ALL POSITIONS)
#######################################

# install.packages(c("readxl","writexl"))
library(readxl)
library(writexl)

# 1) Read data
gk  <- read_excel("player_stats.xlsx", sheet = "GK")
df  <- read_excel("player_stats.xlsx", sheet = "DF")
mf  <- read_excel("player_stats.xlsx", sheet = "MF")
fw  <- read_excel("player_stats.xlsx", sheet = "FW")
map <- read_excel("metric_mapping.xlsx", sheet = "mapping")

# 2) Helper functions
safe_div <- function(x, y) ifelse(y == 0, NA, x / y)

normalize <- function(x){
  r <- range(x, na.rm = TRUE)
  if (r[1] == r[2] || any(!is.finite(r))) return(rep(0.5, length(x)))
  (x - r[1]) / (r[2] - r[1])
}
invert_normalize <- function(x) 1 - normalize(x)

fix_mv <- function(v){
  v <- ifelse(toupper(as.character(v)) == "NO MV", NA, v)
  suppressWarnings(as.numeric(v))
}

# 3) Function to prepare a role (per90, eligible, clean MV)
prepare_role <- function(d, role){
  if (role == "GK") {
    totals <- c("ga","att","cmp","opp","stp")
  } else {
    totals <- c("tkl","tklw","int","tkl_int","clr","blocks",
                "prgc","prgp","prgr","crdy","crdr")
  }
  for (nm in totals){
    if (nm %in% names(d)) d[[paste0(nm,"_per90")]] <- safe_div(d[[nm]], d[["90s"]])
  }
  d$market_value_m <- fix_mv(d$market_value_m)
  d$eligible <- d[["90s"]] >= 5
  d[d$eligible, ]
}

gk <- prepare_role(gk, "GK")
df <- prepare_role(df, "DF")
mf <- prepare_role(mf, "MF")
fw <- prepare_role(fw, "FW")

# 4) Score one role
score_role <- function(d, mapping, role){
  m <- mapping[mapping$pos_grp == role, ]
  need <- m$metric
  miss <- setdiff(need, names(d))
  if (length(miss)>0) {
    cat("⚠️",role,"missing:",paste(miss,collapse=", "),"\n")
    m <- m[!(m$metric %in% miss), ]
    need <- m$metric
  }
  # normalize each metric
  for (i in seq_len(nrow(m))){
    metric <- m$metric[i]
    trans   <- m$transform[i]
    z <- if (trans=="invert_normalize") invert_normalize(d[[metric]]) else normalize(d[[metric]])
    mu <- mean(z,na.rm=TRUE); z[is.na(z)] <- mu
    d[[paste0("z__",metric)]] <- z
  }
  # weighted sum
  zcols <- paste0("z__",need)
  W <- m$weight
  Z <- as.matrix(d[,zcols,drop=FALSE])
  d$TFS_raw <- as.numeric(Z %*% as.matrix(W))
  r <- range(d$TFS_raw,na.rm=TRUE)
  d$TFS <- if(r[1]!=r[2]) 100*(d$TFS_raw-r[1])/(r[2]-r[1]) else 50
  d
}

# 5) Score all roles
gk_scored <- score_role(gk,map,"GK")
df_scored <- score_role(df,map,"DF")
mf_scored <- score_role(mf,map,"MF")
fw_scored <- score_role(fw,map,"FW")

# 6) Combine and add extra indices
all_players <- rbind(gk_scored, df_scored, mf_scored, fw_scored)

all_players$peak_age <- ifelse(all_players$pos_grp=="GK",29,27)
all_players$is_under_peak <- all_players$age < all_players$peak_age

all_players$VMI <- all_players$TFS / log1p(all_players$market_value_m)
all_players$DPI <- ifelse(all_players$is_under_peak,
                          all_players$TFS/(all_players$age/all_players$peak_age),NA)
all_players$PPS <- ifelse(all_players$is_under_peak,
                          all_players$TFS*(1+(all_players$peak_age-all_players$age)/all_players$peak_age),NA)
all_players$MAPI <- ifelse(all_players$is_under_peak,
                           (all_players$DPI*all_players$TFS)/(all_players$market_value_m+1),NA)

# 7) Save results
write_xlsx(
  list(
    GK = gk_scored,
    DF = df_scored,
    MF = mf_scored,
    FW = fw_scored,
    ALL = all_players,
    UNDER_PEAK = all_players[all_players$is_under_peak,]
  ),
  "player_scores_with_indices.xlsx"
)

cat("✅ Done. File saved: player_scores_with_indices.xlsx\n")
