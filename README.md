# knife-data_bag-upgrade

## Description

A defanged proof-of-concept plugin for migrating Chef data bags from the 10.x
format to the new Chef 11 format.  As of this writing, the plugin will
back up data bag items, run the conversion, save a local backup of the new
data bag and *SKIP* uploading the converted data bag item back to the Chef
server.  If you want to test it out, there's just one line of code you need
to uncomment...

## Requirements

* Chef 10 or newer
* Functioning workstation running knife ("knife node list" works)
* Working Chef repo

## Installation

Maybe if this proves useful we'll throw it onto Rubygems.  But for now,
just copy it into either your Chef repository or your home directory:

```
mkdir -p $CHEF_REPO/.chef/plugins/knife
cp data_bag_upgrade.rb $CHEF_REPO/.chef/plugins/knife
```

... or ...

```
mkdir -p ~/.chef/plugins/knife
cp data_bag_upgrade.rb ~/.chef/plugins/knife
```

## Usage

Like most tools that can shoot your foot off, using this plugin is easy.
Just go into your Chef repository and run:

```
knife data bag upgrade --secret-file path/to/secret_key -D backup_directory
```

It will connect to your Chef endpoint using your stored credentials and
walk all of your data bag items.

## License

I (Steven Wagner) am the principal author of this code, though it's based 
on some work by several people at Opscode on other plugins.  I am releasing
it into the world in the hope that it is found to be useful and seek no
compensation (or resposibility) for it of any kind.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
