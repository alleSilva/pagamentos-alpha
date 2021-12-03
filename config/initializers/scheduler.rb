# PoF, LIMITAR A PRODUÇÃO PRA NÃO ATRAPALHAR OS TESTES

if Rails.env.production?
  require 'rufus-scheduler'

  s = Rufus::Scheduler.singleton

  s.every '1d' do
    Rails.logger.info "#{Time.zone.now} criando cobrança de assinaturas"
    # Rails.logger.flush
    CustomerSubscription.renew_subscriptions
  end
end
