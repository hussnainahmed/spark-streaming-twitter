DROP TABLE IF EXISTS senti;
create table senti(
  score int, 
  text String,
  created_at String,
  sentiment String
  ) 
  ROW FORMAT SERDE
    'com.bizo.hive.serde.csv.CSVSerde'
  STORED AS INPUTFORMAT
    'org.apache.hadoop.mapred.TextInputFormat'
  OUTPUTFORMAT
    'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
  LOCATION '/user/flume/sentiment';
