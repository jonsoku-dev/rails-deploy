#!/bin/sh
bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rake db:create RAILS_ENV=production
bundle exec rake db:migrate RAILS_ENV=production
#마지막 명령(exec bundle exec rails server -b 0.0.0.0)에서만 exec를 사용하는 이유는 Rails 서버 프로세스가 컨테이너의 메인 프로세스가 되도록 하기 위함입니다.
#명령이 컨테이너에서 실행되면 자체 프로세스 ID(PID)와 리소스가 있는 새 프로세스에서 실행됩니다. 명령 실행이 완료되면 프로세스가 종료되고 사용 중이던 모든 리소스가 해제됩니다. Docker 컨테이너의 맥락에서 기본 프로세스는 컨테이너의 네임스페이스에서 실행되고 컨테이너의 리소스 관리를 담당하는 프로세스입니다.
#마지막 명령에서 exec를 사용하여 현재 셸 프로세스를 rails server 프로세스로 바꿉니다. 즉, 레일즈 서버 프로세스가 컨테이너의 메인 프로세스가 되어 컨테이너의 리소스 관리를 담당하게 됩니다. exec가 없으면 rails server 프로세스는 현재 프로세스와 PID 및 리소스가 다른 새 프로세스에서 실행되며 현재 프로세스는 컨테이너의 기본 프로세스로 계속 실행됩니다.
#최종 명령에서 exec를 사용하면 컨테이너로 전송된 신호(예: SIGTERM, SIGINT)가 rails server 프로세스에서 적절하게 처리됩니다. 신호가 컨테이너로 전송되면 Docker는 신호를 컨테이너의 기본 프로세스로 전달합니다. exec를 사용하여 rails server 프로세스가 신호를 수신하고 적절하게 처리할 수 있는지 확인합니다.
#요약하면 최종 명령에서만 exec를 사용하는 이유는 Rails 서버 프로세스가 컨테이너의 메인 프로세스가 되도록 하고 컨테이너로 보내는 신호가 제대로 처리되도록 하기 위함입니다.
exec bundle exec rails server -b 0.0.0.0 -e production