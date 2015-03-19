# bookit-seq-smartstock
Takes information from BOOK-IT and creates a sequence file to use with Smartstock

## Preparation

Bundler is taking care of gem dependencies. Install Bundler if you don't have it on your system:
`gem install bundler`

With Bundler in place you install the required gems: `bundle install`

## Instruction
Search by Global change copies in BOOK-IT and save the list as CSV.

The program needs a `shelf_list`. The file in the project is the shelf list for Vimmerby

### Example search string
This is an example of a search string in BOOOK-IT to generate the CSV: `vhb/tg inte mag/pl (A*/hy ELLER B*/hy ELLER C*/hy ELLER E*/hy ELLER D*/hy) inte i/pu inte ref/pl`
