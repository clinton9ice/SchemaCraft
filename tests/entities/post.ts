import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm'
import { User } from './user'

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn()
  id: number

  @Column()
  title: string

  @Column('text')
  content: string

  @ManyToOne(() => User)
  user: User
}
