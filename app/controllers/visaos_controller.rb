class VisaosController < ApplicationController


  before_filter :load_professors
  layout 'exibicao'
  # GET /visaos
  # GET /visaos.xml
  def index
    if !(params[:tipo]).blank?     
      if params[:tipo].to_s == "Fundamental"
        redirect_to fundamental_visaos_path
      else
        if params[:tipo].to_s == "Infantil"
          redirect_to infantil_visaos_path
        else
          redirect_to ambos_visaos_path
        end
      end
    end
  end


  def infantil
    @search = Professor.search(params[:search])
    if !(params[:search].blank?)
        @search = Professor.search(params[:search])
        @professor_rel_geral = @search.all(:joins => :unidade, :conditions => ["unidades.tipo in (1,2,3,7)"], :order => 'pontuacao_final DESC')
    end
  end

  

  def fundamental
      @search = Professor.search(params[:search])
      if !(params[:search].blank?)
              @search = Professor.search(params[:search])
              @professor_rel_geral = @search.all(:joins => :unidade, :conditions => ["unidades.tipo in (4,5,6,7)"], :order => 'pontuacao_final DESC')
      end
  end


  def ambos
      @search = Professor.search(params[:search])
      if !(params[:search].blank?)
              @search = Professor.search(params[:search])
              @professor_rel_geral = @search.all(:joins => :unidade, :conditions => ["unidades.tipo in (1,2,3,4,5,6,7)"], :order => 'pontuacao_final DESC')
      end
  end

  protected

  def load_professors
    @unidades = Unidade.all
    @professors = Professor.find(:all,:joins => :unidade, :conditions => ["unidades.tipo in (1,2,3)"], :order => "matricula")
  end



end
