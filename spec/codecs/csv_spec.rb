# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/csv2"


describe LogStash::Codecs::CSV2 do
    describe "['test1','test2','test3']" do
      subject do
        LogStash::Codecs::CSV2.new({ "fields" => ["test1","test2","test3"]})
      end
      it 'should output empty fields if field is missing' do
        event = LogStash::Event.new({"test1" => "myvalue"})

        subject.on_event do |ev,output|
          expect(output).to match(/myvalue,,/)
        end

        subject.encode(event)
      end

      it 'should output empty fields when no fields are given' do
        event = LogStash::Event.new({})

        subject.on_event do |ev,output|
          expect(output).to match(/,,/)
        end

        subject.encode(event)
      end

      it 'should output correct field in correct place' do
        event = LogStash::Event.new({"test3" => "testvalue"})

        subject.on_event do |ev,output|
          expect(output).to match(/,,testvalue/)
        end

        subject.encode(event)
      end
    end
    describe "col_sep" do
       subject do
        LogStash::Codecs::CSV2.new({ "fields" => ["test1","test2","test3"],"csv_options" => {"col_sep" => ";"}})
      end
      it 'should output correct sep' do
        event = LogStash::Event.new({"test3" => "testvalue3","test2" => "testvalue2","test1" => "testvalue1"})

        subject.on_event do |ev,output|
          expect(output).to match(/testvalue1;testvalue2;testvalue/)
        end

        subject.encode(event)
      end
    end
end
