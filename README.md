# MetStat
# By Aaron Schlafly 3/1/2021

This repository stores files that can be used to read in the reserves from Exhibit 5 of MetLife's statutory filing for the state of New York. This can be done for years 2019 and 2020.

The key R Script is "MetResExtract.R"

The code includes a few specific fixes to typos that are unique to MetLife's filing (e.g "3.75%" is written "3. 75%"). Because the presence of space followed by a period is used to split fields, these typos cause the columns to me incorrectly arranged.

Very little effort has been made to make this data portable. For example, the use of library() assumes that users have installed the libraries that are used. If not, users should install themselves. Similarly, the reading and writing of files assumes the .pdf files are present in the local directory, and no effort has been made to make the coding work on multiple operating systems, locales, etc.

Before the .csv and .json files are created, a table is produced which can be checked against the subtotals ("0X99997. Totals (Gross)" and "0X99998. Reinsurance Ceded" in Exhibit 5).

After considerable work to get the script to read in 2019, the marginal effort required to read in 2020 was very small. It is likely that this code with only a few small adjustments could be used to read in any statutory blanks which are similarly formatted.