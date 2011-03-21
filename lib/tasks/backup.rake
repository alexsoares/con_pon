SHARED_PATH = "/home/servidor/pontuacao.seducpma.com/shared"
DB_BACKUP_DIR = File.join(SHARED_PATH, "db")
BACKUP_SERVER = "alexandre@200.232.60.242:~/backup/pontuacao.seducpma.com"

namespace :backup do
  task :run => :database do
    `rsync -a --delete-excluded #{SHARED_PATH}/ #{BACKUP_SERVER}`
  end

  task :database => :environment do
    FileUtils.mkdir_p(DB_BACKUP_DIR)
    db_backup_file = File.join(DB_BACKUP_DIR, "backup-#{Time.now.strftime("%Y%m$
    `mysqldump --single-transaction --flush-logs --add-drop-table --add-locks -$
    FileUtils.rm(Dir.glob("#{DB_BACKUP_DIR}/*.sql.gz").sort.reverse[5..-1]||[])
  end
end

