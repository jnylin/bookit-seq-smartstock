# bookit-seq-smartstock
Takes information from BOOK-IT and creates a sequence file to use with Inventory Reader (Smartstock or Bibliowand)

## Preparation

Bundler is taking care of gem dependencies. Install Bundler if you don't have it on your system:
`gem install bundler`

With Bundler in place you install the required gems: `bundle install`

## Instruction
Search by Global change copies in BOOK-IT and save the list as CSV.

The program needs a `shelf_list` for each department and maybe also location in BOOK-IT. The files in the project is  shelf lists for Vimmerby Library.

### Settings

By default Smartstock treats an item in sequence if it's discovered within the 10 next och 10 previous items. It's possible to change that in `confige.ini`

`[config.search.sequence]
window=10`


### Example search string
This is an example of a search string in BOOOK-IT to generate the CSV: 
`vhb/tg a/ob 01/pl inte mag/pl (C*/hy ELLER E*/hy ELLER D*/hy) inte i/pu inte små*/pl inte fol/pl inte astr*/pl inte mag*/pl inte infor*/pl inte forskar*/pl`
