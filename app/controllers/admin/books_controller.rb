# coding: utf-8
class Admin::BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def new
    @book = Book.new
  end

  def create
    params[:book] = {
      "title" => "新しい本",
      "author" => "新しい作者",
    }
    Book.new(params[:book])
  end

  def show
    @book = Book.find(params[:id])
  end

end

