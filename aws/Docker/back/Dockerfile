FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html

RUN chmod +r /usr/share/nginx/html/index.html
# docker build -t webserver .
# docker run -it --rm -d -p 8080:80 --name web webserver
CMD ["nginx", "-g", "daemon off;"]