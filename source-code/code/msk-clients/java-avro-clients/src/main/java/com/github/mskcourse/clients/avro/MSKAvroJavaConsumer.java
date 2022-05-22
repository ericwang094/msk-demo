package com.github.mskcourse.clients.avro;

import com.example.Customer;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class MSKAvroJavaConsumer {

    public static void main(String[] args) {
        Properties properties = new Properties();
        // normal consumer
        properties.setProperty("bootstrap.servers", "b-1.msk-demo-cluster.rxt4pb.c2.kafka.eu-west-2.amazonaws.com:9092,b-2.msk-demo-cluster.rxt4pb.c2.kafka.eu-west-2.amazonaws.com:9092,b-3.msk-demo-cluster.rxt4pb.c2.kafka.eu-west-2.amazonaws.com:9092");
        properties.setProperty("group.id", "customer-consumer-group-v1");
        properties.setProperty("auto.commit.enable", "false");
        properties.setProperty("auto.offset.reset", "earliest");

        // avro part (deserializer)
        properties.setProperty("key.deserializer", StringDeserializer.class.getName());
        properties.setProperty("value.deserializer", KafkaAvroDeserializer.class.getName());
        properties.setProperty("schema.registry.url", "http://cp-schema-registry.local:8081");
        properties.setProperty("specific.avro.reader", "true");

        KafkaConsumer<String, Customer> kafkaConsumer = new KafkaConsumer<>(properties);
        String topic = "customer-avro";
        kafkaConsumer.subscribe(Collections.singleton(topic));

        System.out.println("Waiting for data...");

        while (true){
            System.out.println("Polling...");
            ConsumerRecords<String, Customer> records = kafkaConsumer.poll(Duration.ofMillis(5000));

            for (ConsumerRecord<String, Customer> record : records){
                Customer customer = record.value();
                System.out.println(customer);
            }

            kafkaConsumer.commitSync();
        }
    }
}
