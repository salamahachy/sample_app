require 'spec_helper'

describe "Authentication" do
  
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  
  describe "signin page" do
    before { visit signin_path }
    
    it { should have_content('Sign in') }
    it { should have_title('Sign in') }
  end
  
  describe "signin" do
    before { visit signin_path }
    let(:signin) { "Sign in" }
    
    describe "with invalid information" do
      before { click_button signin }
      
      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error')}
      end
    end
    
    describe "with valid information" do
      before { sign_in user }
      
      it { should have_title(user.name) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link(signin, href: signin_path) }
      
      describe "followed by signout" do
        before { click_link "Sign out" }
        
        it { should have_link(signin) }
      end
    end
  end 
  
  describe "authorization" do
    
    describe "for non-signend-in users" do
      
      describe "when attempting to visit a protected parge" do
        before do
          visit edit_user_path(user)
          sign_in user
        end
        
        describe "after signing in" do
          
          it "should render the desired protected page" do
            expect(page).to have_title('Edit user')
          end
        end
      end
      
      describe "in the Users Controller" do
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          
          it { should have_title('Sign in') }
        end
        
        describe "submitting to the update action" do
          before { patch user_path(user) }
          
          specify { expect(response).to redirect_to(signin_path) }
        end
        
        describe "visit the user index" do
          before { visit users_path }
          
          it { should have_title('Sign in') }
        end
        
        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end
      end
      
      describe " in the Microposts controller" do
        
        describe "submitting to the create action" do
          before { post microposts_path }
          specify {expect(response).to redirect_to(signin_path) }
        end
        
        describe "submittin to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify {expect(response).to redirect_to(signin_path) }
        end
      end
    
      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end
    
    describe "as wrong user" do
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
    
        
    describe "as signed in user" do
      
      describe "trying to sign up" do
        before do
          sign_in user
          visit signup_path 
        end
        
        it { should_not have_title('Sign up') }
        it "should redirect to the root_url" do
          expect(current_url).to eq root_url
        end
      end
      
      describe "submitting a POST request to the User#create action" do
        let(:new_user) { FactoryGirl.create(:user) }
        before do 
          sign_in user, no_capybara: true
          post users_path(new_user)
        end
         
        specify { expect(response).to redirect_to(root_url) }
      end              
    end
  end
end
