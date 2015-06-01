# coding: utf-8
class NoticeMailer < ActionMailer::Base
  #デフォルトのヘッダ情報
  default from: "user@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_mailer.sendmail_confirm.subject
  #
  #テストちゃん
  def sendmail_confirm
    @greeting = "Hi"

    mail to: "ne250143@icloud.com"
  end

  #会員登録時の通知メール
  def complete_registration(member)
    @member = member
    mail to: @member.email, :subject => "会員登録手続き完了のお知らせ"
  end
end
