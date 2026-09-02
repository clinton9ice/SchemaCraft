import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany } from 'typeorm'
import { Category } from './category'
import { User } from './user'

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn()
  id: number

  @Column({ unique: true })
  name: string

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number

  @ManyToOne(() => Category)
  category: Category

  @OneToMany(() => User, user => user.id) // This is just for testing
  users: User[]
}
