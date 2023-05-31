# Sử dụng image chứa Ruby và Node.js
FROM ruby:3.2.2

# Thiết lập biến môi trường
ENV RAILS_LOG_TO_STDOUT=true

# Cài đặt các dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  nodejs \
  yarn \
  postgresql-client

# Tạo thư mục làm việc
RUN mkdir /app
WORKDIR /app

# Sao chép mã nguồn ứng dụng vào container
COPY . /app

# Cài đặt dependencies của Rails
RUN bundle install

# Mở cổng 3000 để truy cập ứng dụng
EXPOSE 3000

# Khởi chạy ứng dụng Rails
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
