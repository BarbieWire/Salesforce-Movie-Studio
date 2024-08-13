global class TMDBSyncScheduler implements Schedulable {
    global static void execute(SchedulableContext sc) {
        TMDBSyncBatch batch = new TMDBSyncBatch();
        Database.executeBatch(batch, 200); // second argument is batch size
    }
}
