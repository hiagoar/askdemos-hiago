module Inboxes
  class MessagesController < ApplicationController
    before_action :set_inbox

    def upvote
      @message = @inbox.messages.find(params[:id])
      flash[:notice] = 'voted!'
      if current_user.voted_for? @message
        @message.unliked_by current_user
      else
        @message.liked_by current_user
      end
      redirect_to @inbox
    end

    # GET /messages/new
    def new
      @message = @inbox.messages.new
    end

    # POST /messages or /messages.json
    def create
      @message = @inbox.messages.new(message_params)

      respond_to do |format|
        if @message.save
          format.html { redirect_to @inbox, notice: 'Message was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /messages/1 or /messages/1.json
    def destroy
      @message = @inbox.messages.find(params[:id])
      @message.destroy

      respond_to do |format|
        format.html { redirect_to @inbox, notice: 'Message was successfully destroyed.' }
      end
    end

    private

    def set_inbox
      @inbox = Inbox.find(params[:inbox_id])
    end

    def message_params
      params.require(:message).permit(:body).merge(user: current_user)
    end
  end
end
