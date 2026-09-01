puts "Καθαρίζω τη βάση..."
Item.destroy_all
Todo.destroy_all
User.destroy_all

puts "Δημιουργώ χρήστες..."
maria = User.create!(name: "Maria", email: "maria@example.com", password: "secret123")
giannis = User.create!(name: "Giannis", email: "giannis@example.com", password: "secret456")

puts "Δημιουργώ todos για τη Maria..."
groceries = maria.todos.create!(
  title: "Ψώνια εβδομάδας",
  description: "Σούπερ μάρκετ Σάββατο πρωί",
  completed: false
)
groceries.items.create!([
  { content: "Γάλα", position: 1, completed: true },
  { content: "Ψωμί", position: 2, completed: false },
  { content: "Καφές", position: 3, completed: false }
])

assignment = maria.todos.create!(
  title: "Rails assignment",
  description: "JWT authentication + Todos CRUD με scoping ανά χρήστη",
  completed: false
)
assignment.items.create!([
  { content: "Part 4 - CRUD", position: 1, completed: true },
  { content: "Part 5 - filters & README", position: 2, completed: false },
  { content: "Παρουσίαση", position: 3, completed: false }
])

maria.todos.create!(
  title: "Ραντεβού οδοντίατρος",
  description: "Τηλέφωνο 210-0000000",
  completed: true
)

puts "Δημιουργώ todos για τον Giannis..."
gym = giannis.todos.create!(title: "Γυμναστήριο", description: "Δευτέρα-Τετάρτη-Παρασκευή", completed: false)
gym.items.create!([
  { content: "Πρόγραμμα από τον γυμναστή", position: 1, completed: true },
  { content: "Νέα παπούτσια", position: 2, completed: false }
])

giannis.todos.create!(title: "Πληρωμή ΔΕΗ", completed: true)

puts "-" * 40
puts "Users: #{User.count}"
puts "Todos: #{Todo.count}"
puts "Items: #{Item.count}"
puts "Login: maria@example.com / secret123"
puts "Login: giannis@example.com / secret456"