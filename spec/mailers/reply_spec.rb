require "rails_helper"

RSpec.describe ReplyMailer, type: :mailer do
  describe "reply_mailer" do
    let(:mail) { ReplyMailer.reply_mailer }

    it "renders the headers" do
      expect(mail.subject).to eq("Reply mailer")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "notification" do
    let(:mail) { ReplyMailer.notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end