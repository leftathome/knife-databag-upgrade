#
# Author:: Steven Wagner (leftathome@gmail.com)
# Author:: Steven Danna (steve@opscode.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/node'
require 'chef/api_client'

module DataBagUpgrade
  class DataBagUpgrade < Chef::Knife::DataBagFromFile

    banner "knife data bag upgrade"
    category "data bag"

      deps do
        require 'chef/data_bag_item'
        require 'chef/encrypted_data_bag_item'
      end

      option :backup_dir,
      :short => "-D BACKUP_DIR",
      :long  => "--backup-dir ",
      :description => "Directory in which to store a structured backup of your data bags."

      option :secret,
      :short => "-s SECRET",
      :long  => "--secret ",
      :description => "The secret key to use to encrypt data bag item values"

      option :secret_file,
      :long => "--secret-file SECRET_FILE",
      :description => "A file containing the secret key to use to encrypt data bag item values"

# cribbed from Chef::Knife::DataBagEdit
      def load_item(bag, item_name)
        item = Chef::DataBagItem.load(bag, item_name)
        if use_encryption
          begin
            Chef::EncryptedDataBagItem.new(item, read_secret).to_hash
          rescue NoMethodError
            ui.info "Looks like #{bag}::#{item_name} isn't encrypted?"
            item
          rescue OpenSSL::Cipher::CipherError
            ui.warn "Looks like #{bag}::#{item_name} was encrypted, but with a different key!"
          end
        else
          item
        end
      end

    def run
      unless config[:backup_dir]
        ui.info "You have not specified a backup directory!"
        ui.info "This plugin walks your server's data bags and modifies them..."
        ui.info "So you really should back all that stuff up."
        ui.info "You know, in case something goes wrong and you need to roll back."
        return 1
      end
      ui.msg "Walking data bags"
      dir = File.join(config[:backup_dir]) 
      FileUtils.mkdir_p(dir)
      Chef::DataBag.list.each do |bag_name, url|
        FileUtils.mkdir_p(File.join(dir, bag_name))
        Chef::DataBag.load(bag_name).each do |item_name, url|
          ui.msg "Examining data bag #{bag_name} item #{item_name}"
          item = load_item(bag_name,item_name)
          # back up the old version before we start messing with it.
          begin
            File.open(File.join(dir, bag_name, "#{item_name}-old.json"), "w") do |dbag_file|
              dbag_file.print(item.to_json)
            end
          rescue NoMethodError
            ui.warn "Refusing to back up unreadable object data_bag_item[#{bag_name}::#{item_name}] ..."
          end
          dbag = Chef::DataBagItem.new
          dbag.data_bag(bag_name)
          begin
            dbag.raw_data = item
            File.open(File.join(dir, bag_name, "#{item_name}-new.json"), "w") do |dbag_file|
              dbag_file.print(dbag.raw_data.to_json)
            end
          rescue Chef::Exceptions::ValidationFailed
            ui.warn "Will not update invalid object data_bag_item[#{dbag.data_bag}::#{item_name}] ... check upstream for errors"
            next
          end
          ui.info("Would save: #{dbag.raw_data.inspect}")
          #dbag.save
          ui.info("Updated data_bag_item[#{dbag.data_bag}::#{dbag.id}]")
          
          #File.open(File.join(dir, bag_name, "#{item_name}.json"), "w") do |dbag_file|
          #  dbag_file.print(item.raw_data.to_json)
          #end
        end
      end
    end

  end
end
