
class TituloProfessor < ActiveRecord::Base 
  validates_presence_of :professor_id, :message => ' -  PROFESSOR - PREENCHIMENTO OBRIGATÓRIO'
  validates_presence_of :titulo_id, :message => ' -  TITULO - PREENCHIMENTO OBRIGATÓRIO'
  validates_numericality_of :quantidade,:if => :verify_qtd?, :message => ' - Acima de 30 hrs'

  belongs_to :professor
  belongs_to :titulo, :class_name => 'Titulacao', :foreign_key => "titulo_id"
  DTA = Date.today


  before_save :verifica_valor_titulos
  validate :verify_qtd?
  before_destroy :atualiza_valor_total_apos_delecao


protected


  def verify_qtd?
    if !(self.tipo_curso == true) and self.titulo_id == 7
      if self.quantidade < 30
        errors.add(:tipo_curso, 'Curso à distancia somente acima de 30 hrs de duração')
      end
    end
  end

  def verifica_valor_titulos
      self.obs.upcase!
      self.ano_letivo = Time.current.strftime("%Y")
      if self.titulo_id == 6
        self.tipo_curso = 1
      end
      @titulacao = Titulacao.find(self.titulo_id)
      @atualiza_professor = Professor.find(self.professor_id)
      self.valor = @titulacao.valor
      if (self.titulo_id == 1) or (self.titulo_id == 2) or (self.titulo_id == 3) or (self.titulo_id == 4) or (self.titulo_id == 5)
        self.pontuacao_titulo = self.quantidade * self.valor
        self.status = 1
        @atualiza_professor.total_titulacao = @atualiza_professor.total_titulacao + self.pontuacao_titulo
        @atualiza_professor.save
      else
        @dta = ((DTA.strftime("%Y").to_i) - 1).to_s + "-11-01"
        if self.dt_titulo < @dta.to_date
          self.status = 0
        else
          if (self.titulo_id == 6) or (self.titulo_id == 7) or (self.titulo_id == 8)
           #self.dt_titulo = (DTA.strftime("%Y").to_i).to_s + "-06-30"
           self.dt_validade = ((DTA.strftime("%Y").to_i)).to_s + "-06-30"
           #self.dt_validade = "2010"
           self.pontuacao_titulo = self.quantidade * self.valor
           teste = DTA.strftime("%Y-%m-%d").to_date

           if (self.dt_titulo.to_s > "2010-06-30") or (self.dt_titulo.to_s < "2009-11-01")
             self.status = 0
           else
             @atualiza_professor.total_titulacao = @atualiza_professor.total_titulacao + self.pontuacao_titulo
             @atualiza_professor.save
             self.status = 1
           end
          end
        end
      end
  end


  def atualiza_valor_total_apos_delecao
    if self.status == true
      @prof_total_trabalhado = Professor.find(self.professor_id)
      @prof_total_trabalhado.total_titulacao = @prof_total_trabalhado.total_titulacao - self.pontuacao_titulo
      @prof_total_trabalhado.pontuacao_final = @prof_total_trabalhado.total_titulacao + @prof_total_trabalhado.total_trabalhado
      @prof_total_trabalhado.save
    end
  end

  def self.titulo_permanente(professor)
    TituloProfessor.all(:joins => :titulo, :conditions => ['professor_id = ? and titulacaos.tipo = "PERMANENTE"',professor])
  end

  def self.titulo_anual(professor)
    TituloProfessor.all(:joins => :titulo, :conditions => ['professor_id = ? and titulacaos.tipo = "ANUAL"',professor])
  end


  #professor_current busca professores para os usuários "administrador" "planejamento" "supervisao"
  def self.professor_current(professor)
    Professor.all(:conditions => ['id= ?', professor])
  end

  #professor_normal busca professores para os outros usuários
  def self.professor_normal(professor,regiao)
    Professor.all(:conditions => ['id = ? and (sede_id = ? and sede_id = 54)',professor,regiao])    
  end

  def self.professor_consulta_titulo_permanente(titulo,regiao)
    Professor.all(:joins => :titulo_professors, :conditions =>['titulo_professors.titulo_id = ? and (p.sede_id = ? or p.sede_id = 54)', titulo,regiao],:select => "DISTINCT professors.*")
  end
  
  def self.professor_consulta_titulo_anual(titulo,regiao,ano_letivo)
    Professor.all(:joins => :titulo_professors, :conditions =>['titulo_professors.titulo_id = ? and titulo_professors.ano_letivo = ? and (p.sede_id = ? or p.sede_id = 54)', titulo,ano_letivo,regiao],:select => "DISTINCT professors.*",:page=>params[:page],:per_page =>2)
  end

  def self.verify(professor,ano_letivo,titulo)
    if (titulo == 1 or titulo == 2 or titulo == 3 or titulo == 4 or titulo == 5) then
      TituloProfessor.find(:all,:joins => :titulo, :conditions => ['titulacaos.id = ? and professor_id = ? and ano_letivo = ?',titulo,professor])
    else
      @tp = TituloProfessor.find(:all,:joins => :titulo, :conditions => ['titulacaos.id = ? and professor_id = ? and ano_letivo = ?',titulo,professor,ano_letivo])
    end

  end

  def self.check_titulos(ano_letivo,professor)
   find_by_professor_id(professor,:joins => :professor, :select => "professors.total_titulacao as total_titulacao, professors.total_trabalhado as total_trabalhado, professors.pontuacao_final as pontuacao_final, sum(pontuacao_titulo) as soma_pont_titulo", :conditions => ["(titulo_id in (1,2,3,4,5) or ( ano_letivo = ? and status = 1))",ano_letivo])
  end

end
