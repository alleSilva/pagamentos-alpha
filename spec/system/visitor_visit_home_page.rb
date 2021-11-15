require 'rails_helper'

describe 'Visitor visits homepage' do
    it 'and see login and registration buttons' do
        visit root_path

        expect(page).to have_link('Registrar como usuário', href: new_user_registration_path)
        expect(page).to have_link('Logar como usuário', href: new_user_session_path)
        expect(page).to have_link('Registrar como administrador', href: new_admin_registration_path)
        expect(page).to have_link('Logar como administrador', href: new_admin_session_path)
    end
end
