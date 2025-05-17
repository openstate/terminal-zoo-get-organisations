# name: terminal-zoo-get-organisations
# about: Get data from organisaties.overheid.nl
# version: 0.0.1
# authors: Open State
# url: https://github.com/yourusername/basic-plugin
require 'sidekiq/api'

class ::Organisation < ActiveRecord::Base

end

def create_user(name, email)
    username = name.parameterize[0, 60]
    if username.end_with?('-')
        username = username[0, 59]
    end

    new_user_params = {
        name: name,
        email: email,
        username: username,
        username_lower: username.downcase,
        active: true,
        approved: true
    }
    user ||= User.new
    user.attributes = new_user_params
    ReviewableUser.set_approved_fields!(user, Discourse.system_user)

    user.save!
end

def get_organisations
    print "Start of get_organisations!"

    doc = Nokogiri::XML(File.open("plugins/terminal-zoo-get-organisations/exportOO.xml"))
    organisations = []

    doc.xpath("//p:organisatie").each do |organisation|
        system_identifier = organisation['p:systeemId']
        name = organisation.xpath("./p:naam/text()")[0].to_s
        woo_email = organisation.xpath(".//p:naam[text()='Woo-contactpersoon']/..//p:email/text()")[0].to_s

        if EmailAddressValidator.valid_value?(woo_email)
            if !User.find_by_email(woo_email)
                create_user(name, woo_email)
            end
        else
            woo_email = nil
        end

        db_org = {system_identifier: system_identifier, name: name, woo_email: woo_email}
        organisations << db_org
    end

    if organisations.length > 0
        ::Organisation.upsert_all(organisations, unique_by: :system_identifier)
    end

    print "End of get_organisations!"
end


after_initialize do
    get_organisations()
end