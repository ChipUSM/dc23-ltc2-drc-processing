#               GDS             TOP
# RUN=Run1    # LTC2.gds        LTC2
# RUN=Run2    # LTC2.gds        LTC2
# RUN=Run3    # LTC2_IO3a2.gds  LTC2
# RUN=Run4    # LTC2_IO3a2.gds  LTC2
# RUN=Run5    # LTC2_IO3a2.gds  LTC2
# RUN=Run6    # LTC2.gds        LTC2
# RUN=Run7    # LTC2.gds        LTC2
# RUN=Run8    # cm_nmos.gds     cm_nmos
# RUN=Run9    # cm_nmos.gds     cm_nmos
# RUN=Run10   # cm_nmos.gds     cm_nmos
# RUN=Run11   # LTC2.gds        LTC2
# RUN=Run12   # LTC2.gds        LTC2
# RUN=Run13   # LTC2.gds        LTC2
# RUN=Run14	GDS=$(RUN)/LTC2.gds	TOP=LTC2
# RUN=CMC_drc_results_Run1 GDS=$(RUN)/LTC2.gds TOP=LTC2 DRC_REPORT=$(RUN)/IDDMIMS2.strm.ascii.txt DRC_SUMMARY=UNDEFINED
# RUN=Run15 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# RUN=Run16 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary

# RUN=Run17 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# Errors
# - All COMP and POLY Errors
# - Dummy Metal 5 uses different box size, it should be 2x2um
# - Dummy Metals on Fuse TOP
# - Dummy Metals with less than 6um from PMNDMY
# Conclutions
## M5 is not considered a MetalTOP.
## Spacing between M5 indicates no problem with 2.0. Test with 1.2

# RUN=Run18 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# Errors
# - Metal errors are fixed. Waiting for CMC report.

# RUN=Run19 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# Errors
# - Only POLY errors
# - DFC.1a Something about 20um ...
# - DFC.1b Density of 25%

# RUN=Run20 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# I'm adding COMP fillers
# This doesn't indicates any COMP error, only POLY
# Does previous drc evaluation has them? YES

# RUN=Run22 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# Filler made with Padring

# RUN=Run23 GDS=$(RUN)/LTC2.gds TOP=top DRC_REPORT=$(RUN)/$(TOP).drc.results DRC_SUMMARY=$(RUN)/$(TOP).drc.summary
# Fillers are going to be added by GF. GDS is the same of Run16 I think.

# RUN=CMC_drc_results_Run1 GDS=$(RUN)/LTC2.gds TOP=LTC2 DRC_REPORT=$(RUN)/IDDMIMS2.strm.ascii.txt DRC_SUMMARY=UNDEFINED


RUN=CMC_drc_results_Run2
GDS=$(RUN)/LTC2.gds
TOP=IDDMIMS2
DRC_REPORT=$(RUN)/IDDMIMS2.strm.ascii.txt
DRC_SUMMARY=$(RUN)/$(TOP).drc.summary



DRC_REPORT_EDITED=$(DRC_REPORT).edited
DRC_LYRDB=$(abspath $(DRC_REPORT_EDITED).filtered.lyrdb)  # Filtered and edited lyrdb
#DRC_LYRDB=$(abspath $(DRC_REPORT_EDITED).lyrdb)          # Just basic editing


all: klayout

# Summary Information
# Indicates which layers are used, how much drc errors are
# and which cell contains them

# Result files is a mapping between drc error and the layout
# Can be opened directly from klayout, then saved as a lyrdb
filter-results:
	source ./parse-results.sh \
		&& main_results $(DRC_REPORT) \
		&& main_summary $(DRC_SUMMARY)

# LYRDB is a format based on XML that klayout uses for drc information
# Klayout generates the lyrdb from the results file
filter-lyrdb:
	python parse-lyrdb.py $(DRC_REPORT_EDITED).lyrdb


KLAYOUT_RCFILE=klayoutrc
KLAYOUT=klayout -t
ifneq (,$(wildcard $(KLAYOUT_RCFILE)))
KLAYOUT=klayout -t -c $(KLAYOUT_RCFILE)
else
$(call WARNING_MESSAGE, klayoutrc not found)
endif

# Necessary to generate the lyrdb
raw: filter-results
	$(KLAYOUT) -e $(GDS) -m $(DRC_REPORT_EDITED)

# Reading the 
klayout: filter-lyrdb
ifneq (, $(DRC_LYRDB))
	$(KLAYOUT) -e $(GDS) -m $(DRC_LYRDB)
else
	$(KLAYOUT) -e $(GDS)
endif