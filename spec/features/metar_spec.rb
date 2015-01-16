require 'spec_helper'

desscribe "METARS API" do
	it 'sends raw data for specified airfield' do
		get '/metars?stationString=kden'

		expect(response).to be_success		# test for 200 status-code

		json
		expect (json[:metars][:raw_data]).to eq("")
	end

end

