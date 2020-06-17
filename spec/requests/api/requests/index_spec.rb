# frozen_string_literal: true

RSpec.describe 'GET /request, can get all requests' do
  let(:user) { create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }

  let(:requester) { create(:user, email: 'requester@mail.com')}
  let!(:request) { 7.times { create(:request, requester: requester) } }

  let!(:offer) { create(:offer, helper: user, request: Request.first) }

  describe 'without authentication' do
    before do
      get '/api/requests' 
    end
  
    describe 'successfully gets the requests' do
      it 'has a 200 response' do
        expect(response).to have_http_status 200
      end
  
      it 'contains all the requests' do
        expect(response_json['requests'].length).to eq 7
      end
  
      describe 'has keys' do
        it ':id' do
          expect(response_json['requests'][0]).to have_key 'id'
        end
  
        it ':title' do
          expect(response_json['requests'][0]).to have_key 'title'
        end
  
        it ':description' do
          expect(response_json['requests'][0]).to have_key 'description'
        end
  
        it ':requester' do
          expect(response_json['requests'][0]).to have_key 'requester'
        end
      end
  
      describe 'does not have keys' do
        it ':created_at' do
          expect(response_json['requests'][0]).not_to have_key 'created_at'
        end
      end
    end
  end

  describe 'with authentication' do
    before do
      get '/api/requests',
          headers: headers
    end

    it 'includes the offerable key' do
      binding.pry
      expect(response_json['requests'][0]).to have_key 'offerable'
    end

    it "offerable is false on user's own requests" do
      binding.pry
      expect(response_json['requests'].find {|r| r.id == @request.id }['offerable']).to eq false
    end
  end
end
