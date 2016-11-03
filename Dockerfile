FROM trekr5/dashing:latest

ENV DASHBOARD graphite 

RUN dashing new $DASHBOARD && \
        chmod 777 $DASHBOARD 

RUN rm -rf /$DASHBOARD/jobs && \ 
    rm -rf /$DASHBOARD/public && \
    rm -rf /$DASHBOARD/assets && \
    rm -rf /$DASHBOARDS/dashboards && \
    rm -rf /$DASHBOARD/widgets && \
    rm -rf /$DASHBOARD/jobs/twitter.rb && \
    rm -rf /$DASHBOARD/jobs/buzzwords.rb && \
    rm -rf /$DASHBOARD/jobs/sample.rb && \
    rm -rf /$DASHBOARD/jobs/convergence.rb && \
    rm -rf /$DASHBOARD/dashboards/sample.erb && \
    rm -rf /$DASHBOARD/dashboards/sampletv.erb && \
    rm -rf /$DASHBOARD/assets/javascripts/application.coffee && \
    rm -rf /$DASHBOARD/assets/stylesheets/application.scss && \
    rm -rf /$DASHBOARD/config.ru && \
    rm -rf /$DASHBOARD/Gemfile && \
    rm -rf /$DASHBOARD/Gemfile.lock

ADD jobs /$DASHBOARD/jobs
ADD assets /$DASHBOARD/assets
ADD dashboards /$DASHBOARD/dashboards
ADD public /$DASHBOARD/public
ADD widgets /$DASHBOARD/widgets
ADD lib /$DASHBOARD/lib

COPY Gemfile /$DASHBOARD/
COPY Gemfile.lock /$DASHBOARD/
COPY config.ru /$DASHBOARD/
RUN cd $DASHBOARD && \
        bundle install

CMD cd $DASHBOARD;dashing start

