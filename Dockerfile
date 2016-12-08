#FROM trekr5/dashing:latest
FROM artifactory.justgiving.com/base/base-dashing:1.0.8

ENV DASHBOARD graphite 

RUN dashing new $DASHBOARD && \
        chmod 777 $DASHBOARD 

RUN rm -rf /$DASHBOARDS/dashboards && \
    rm -rf /$DASHBOARD/widgets && \
    rm -rf /$DASHBOARD/jobs/twitter.rb && \
    rm -rf /$DASHBOARD/jobs/buzzwords.rb && \
    rm -rf /$DASHBOARD/jobs/sample.rb && \
    rm -rf /$DASHBOARD/jobs/convergence.rb && \
    rm -rf /$DASHBOARD/assets/javascripts/application.coffee && \
    rm -rf /$DASHBOARD/assets/stylesheets/application.scss && \
    rm -rf /$DASHBOARD/config.ru && \
    rm -rf /$DASHBOARD/Gemfile && \
    rm -rf /$DASHBOARD/Gemfile.lock && \ 
    rm -rf /$DASHBOARD/assets/stylesheets/jquery.gridster.min.css 

ADD jobs /$DASHBOARD/jobs
ADD dashboards /$DASHBOARD/dashboards
ADD widgets /$DASHBOARD/widgets
ADD assets/images /$DASHBOARD/assets/images
ADD lib /$DASHBOARD/lib

COPY Gemfile /$DASHBOARD/
COPY Gemfile.lock /$DASHBOARD/
COPY config.ru /$DASHBOARD/
COPY application.scss /$DASHBOARD/assets/stylesheets/
COPY application.coffee /$DASHBOARD/assets/javascripts/

RUN cd $DASHBOARD && \
        bundle install

EXPOSE 3030

CMD cd $DASHBOARD;dashing start

