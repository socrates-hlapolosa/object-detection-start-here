import os
import json
from kafka import KafkaConsumer, KafkaProducer
from prediction import predict
from kafka.errors import KafkaError
import logging


logging.basicConfig(level=logging.INFO)
KAFKA_BOOTSTRAP_SERVER = os.getenv('KAFKA_BOOTSTRAP_SERVER')
KAFKA_CONSUMER_GROUP = 'object-detection-consumer-group'
KAFKA_CONSUMER_TOPIC = os.getenv('KAFKA_TOPIC_IMAGES')
KAFKA_PRODUCER_TOPIC = os.getenv('KAFKA_TOPIC_OBJECTS')


def main():
    # Normally, we'd never want to lose a message,
    # but we want to ignore old messages for this demo, so we set
    # enable_auto_commit=False
    # auto_offset_reset='latest' (Default)
    # This has the effect of starting from the last message.

    consumer = KafkaConsumer(
        KAFKA_CONSUMER_TOPIC,
        group_id=KAFKA_CONSUMER_GROUP,
        bootstrap_servers=KAFKA_BOOTSTRAP_SERVER,
        api_version=(0,10,2)
    )

    producer = KafkaProducer(

        bootstrap_servers=KAFKA_BOOTSTRAP_SERVER, value_serializer=lambda v: json.dumps(v).encode(),

    )

    print(f'Subscribed to "{KAFKA_BOOTSTRAP_SERVER}" consuming topic "{KAFKA_CONSUMER_TOPIC}, producing messages on topic "{KAFKA_PRODUCER_TOPIC}"...')

    try:
        for record in consumer:
            msg = record.value.decode('utf-8')
            dict = json.loads(msg)
            result = predict(dict)
            dict['prediction'] = result
            producer.send(KAFKA_PRODUCER_TOPIC, json.dumps(dict).encode('utf-8'))
            producer.flush()
    except KafkaError as ex:
        logging.error(f"Exception {ex}")
    else:
        logging.info(f"Published message {message} into topic {self.kafka_topic}")
    finally:
        print("Closing KafkaTransformer...")
        consumer.close()
    print("Kafka transformer stopped.")


if __name__ == '__main__':
    main()

