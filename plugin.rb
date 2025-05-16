# name: terminal-zoo-get-organisations
# about: Get data from organisaties.overheid.nl
# version: 0.0.1
# authors: Open State
# url: https://github.com/yourusername/basic-plugin
class ::Organisation < ActiveRecord::Base

end

def get_organisaties
    print "RVD in get_organisaties!"
    ::Organisation.delete_all()
    doc = Nokogiri::XML(File.open("plugins/terminal-zoo-get-organisations/exportOO.xml"))
    organisations = []
    doc.xpath("//p:organisatie").each do |organisation|
        system_identifier = organisation['p:systeemId']
        name = organisation.xpath("./p:naam/text()")[0].to_s
        woo_email = organisation.xpath(".//p:naam[text()='Woo-contactpersoon']/..//p:email/text()")[0].to_s
        if woo_email.blank?
            woo_email = nil
        # else
        #     UsersController
        end
        print("org: #{system_identifier} #{name} #{woo_email}")
        db_org = {system_identifier: system_identifier, name: name, woo_email: woo_email}
        organisations << db_org
    end
    if organisations.length > 0
        ::Organisation.insert_all organisations
    end

    print "RVD end of get_organisaties!"
end


after_initialize do
  # Code which should run after Rails has finished booting
    get_organisaties()
end