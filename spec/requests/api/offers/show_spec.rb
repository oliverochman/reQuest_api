# frozen_string_literal: true

RSpec.describe 'GET /api/offers/:id', type: :request do
  let(:requester) { create(:user) }
  let(:request) { create(:request, requester_id: requester.id) }

  let(:helper) { create(:user) }
  let(:helper_credentials) { helper.create_new_auth_token }
  let(:helper_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(helper_credentials) }

  let(:generic_offer) do
    create(:offer, helper_id: helper.id, request_id: request.id)
  end

  describe 'successfully with valid params and headers' do
    describe 'for pending request' do
      let(:offer) do
        create(:offer,  status: 'pending', message: 'I can help you', helper_id: helper.id, request_id: request.id)
      end

      before do
        get "/api/offers/#{offer.id}",
            headers: helper_headers
      end
  
      it 'has 200 response' do
        expect(response).to have_http_status 200
      end
  
      it 'responds offer message' do
        expect(response_json['offer']['message']).to eq 'I can help you'
      end
  
      it 'responds offer status' do
        expect(response_json['offer']['status']).to eq 'pending'
      end
  
      it 'responds with offer status message' do
        expect(response_json['status_message']).to eq 'Your offer is pending'
      end
    end

    describe 'for accepted request' do
      let(:offer) do
        create(:offer, status: 'accepted', message: 'I can help you', helper_id: helper.id, request_id: request.id)
      end

      before do
        get "/api/offers/#{offer.id}",
            headers: helper_headers
      end

      it 'responds offer status' do
        expect(response_json['offer']['status']).to eq 'accepted'
      end
  
      it 'responds with offer status message' do
        expect(response_json['status_message']).to eq 'Your offer has been accepted'
      end
    end

    describe 'for declined request' do
      let(:offer) do
        create(:offer, status: 'declined', message: 'I can help you', helper_id: helper.id, request_id: request.id)
      end

      before do
        get "/api/offers/#{offer.id}",
            headers: helper_headers
      end

      it 'responds offer status' do
        expect(response_json['offer']['status']).to eq 'declined'
      end
  
      it 'responds with offer status message' do
        expect(response_json['status_message']).to eq 'Your offer has been declined'
      end
    end
  end

  describe 'unsuccessfully when' do
    describe 'user is not logged in' do
      before do
        get "/api/offers/#{generic_offer.id}"
      end

      it 'has 401 response' do
        expect(response).to have_http_status 401
      end
  
      it 'responds error message' do
        expect(response_json['errors'].first).to eq 'You need to sign in or sign up before continuing.'
      end
    end

    describe 'offer cant be found' do
      before do
        get "/api/offers/1000",
            headers: helper_headers
      end

      it 'has 500 response' do
        expect(response).to have_http_status 500
      end
  
      it 'responds error message' do
        expect(response_json['error_message']).to eq "Couldn't find Offer with 'id'=1000 [WHERE \"offers\".\"helper_id\" = $1]"
      end
    end

    describe "user tries to see someone someone else's offer" do
      let(:another_offer) { create(:offer) }

      before do
        get "/api/offers/#{another_offer.id}",
            headers: helper_headers
      end

      it 'has 500 response' do
        expect(response).to have_http_status 500
      end
  
      it 'responds error message' do
        expect(response_json['error_message']).to eq "Couldn't find Offer with 'id'=#{another_offer.id} [WHERE \"offers\".\"helper_id\" = $1]"
      end
    end
  end
end
