require 'spec_helper'

describe MWS::Query do
  let(:query_params) {{
    verb: "GET",
    uri: "/",
    host: "mws-eu.amazonservices.com",
    aws_access_key_id: "key",
    aws_secret_access_key: "secret",
    action: "ListOrders",
    seller_id: "Seller ID",
    version: "2010-01-01",
    timestamp: Time.new(2013, 01, 01)
  }}

  let(:query) {MWS::Query.new(query_params)}

  describe "Initialization" do
    it "should create a MWS::Query object" do
      subject.class.should eq(MWS::Query)
    end

    it "should have some default params" do
      subject.uri.should eq("/")
      subject.verb.should eq("GET")
      subject.signature_method.should eq("HmacSHA256")
      subject.signature_version.should eq(2)
      subject.timestamp.class.should eq(Time)
    end
  end

  describe "Build query" do
    it "should build a simple query" do
      generated_query = "AWSAccessKeyId=key&Action=ListOrders&SellerId=Seller+ID&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2013-01-01T00%3A00%3A00-02%3A00&Version=2010-01-01"
      query.build_query.should eq(generated_query)
    end

    it "should build a query with a signature" do
      query.build_query("signature").include?("Signature=signature").should eq true
    end

    it "should be a query with custom params" do
      builded_query = MWS::Query.new(query_params.merge(params: {custom_param: "custom"})).build_query
      builded_query.should include("CustomParam=custom")
    end
  end

  describe "canonical string" do
    it "should generate a canonical string" do
      canonical = "GET\nmws-eu.amazonservices.com\n/\nAWSAccessKeyId=key&Action=ListOrders&SellerId=Seller+ID&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2013-01-01T00%3A00%3A00-02%3A00&Version=2010-01-01"
      query.canonical.should eq(canonical)
    end
  end

  describe "signature" do
    it "should generate a valid signature" do
      query.signature.should eq("7XZO1dSv7BHElkee33Rt7L5PNFiBET13pg3pOWKeoo0=")
    end
  end

  describe "request_uri" do
    it "should generate a valid request uri" do
      request_uri = "https://mws-eu.amazonservices.com/?AWSAccessKeyId=key&Action=ListOrders&SellerId=Seller+ID&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2013-01-01T00%3A00%3A00-02%3A00&Version=2010-01-01&Signature=7XZO1dSv7BHElkee33Rt7L5PNFiBET13pg3pOWKeoo0%3D"
      query.request_uri.should eq(request_uri)
    end
  end

  describe MWS::Query::Helpers do
    subject {MWS::Query::Helpers}

    describe "escape_date_time_params(params={})" do
      let(:time) {Time.new(2013, 01, 01)}

      it "should escape a simple hash" do
        subject.escape_date_time_params(time: time).should eq({time: time.iso8601})
      end

      it "should escape a nested hash" do
        subject.escape_date_time_params(time: {time: time}).should eq({time: {time: time.iso8601}})
      end
    end

    describe "camelize_keys(parmas={})" do
      it "should camelize a simple hash" do
        subject.camelize_keys(new_key: "value").should eq("NewKey" => "value")
      end

      it "should camelize a nested hash" do
        subject.camelize_keys(key: {key: "value"}).should eq("Key" => {"Key" => "value"})
      end
    end
  end
end