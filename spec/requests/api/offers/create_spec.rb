RSpec.describe 'POST /offers, user can offer to help' do
  let(:requester) { create(:user, email: 'requester@mail.com') }
  let(:req_creds) { requester.create_new_auth_token }
  let(:req_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(req_creds) }

  let(:helper) { create(:user) }
  let(:helper_credentials) { helper.create_new_auth_token }
  let(:helper_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(helper_credentials) }
  
  let(:request) { create(:request, requester: requester) }

  describe 'with authentication and correct params' do
    before do
      post '/api/offers',
           headers: helper_headers,
           params: { request_id: request.id, message: "Hi, I can help!" }
    end

    it 'responds with status 200' do
      expect(response).to have_http_status 200
    end

    it 'responds with a success message' do
      expect(response_json['message']).to eq "Your offer has been sent!"  
    end

    describe 'it creates an offer with' do
      before do
        @offer = Offer.last
      end

      it 'the sending user as helper' do
        expect(@offer.helper).to eq helper
      end

      it 'the request it is associated with' do
        expect(@offer.request).to eq request
      end

      it 'the message' do
        expect(@offer.message).to eq 'Hi, I can help!'
      end
    end
  end

  describe 'requester tries to offer to help himself' do
    before do
      post '/api/offers',
           headers: req_headers,
           params: { request_id: request.id, message: "Hi, I can help!" }
    end

    it 'gives an error status' do
      expect(response).to have_http_status 422
    end

    it 'gives an error message' do
      expect(response_json['message']).to eq 'You cannot offer help on your own request!'
    end
  end

  describe 'user has already offered to help' do
    before do
      create(:offer, helper: helper, request: request)
      post '/api/offers',
            headers: helper_headers,
            params: { request_id: request.id, message: 'Hi, I can help!' }
    end

    it 'gives an error status' do
      expect(response).to have_http_status 422
    end

    it 'gives an error message' do
      expect(response_json['message']).to eq 'Helper is already registered with this request'
    end
  end

  describe 'without authentication but correct params' do
    before do
      post '/api/offers',
           params: { request_id: request.id, message: "Hi, I can help!" }
    end

    it 'gives an error status' do
      expect(response).to have_http_status 401
    end

    it 'gives an error message' do
      expect(response_json['errors'][0]).to eq 'You need to sign in or sign up before continuing.'
    end
  end
end